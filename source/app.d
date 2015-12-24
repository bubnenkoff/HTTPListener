import vibe.d;
import std.stdio;
import std.conv;
import std.algorithm;
import std.datetime;
import std.path;
import std.file;

import ddbc.all;
import parseconfig;
import dbconnect;
import users;

DBConnect db;

//DateTime currentdt;
//static this()
//{
//    DateTime currentdt = cast(DateTime)(Clock.currTime()); // It's better to declarate globally
//    string datestamp = currentdt.toISOExtString;
//}

string roothtml;
static this()
{
    roothtml = buildPath(getcwd, "html") ~ "\\";
    if(!roothtml.exists)
       writeln("[ERROR] HTML dir do not exists");     
}

void main()
{
  
    auto router = new URLRouter;
    router.get("/*", serveStaticFiles(roothtml ~ "pages\\"));    
    router.get("*", serveStaticFiles(roothtml ~ "static\\"));
    router.get("/admin/*", &adminpage);
    
    router.any("*", &accControl);
    router.any("/my", &action);
    router.any("/stat", &statistic);

    router.any("/checkAuthorization", &checkAuthorization);
    router.any("/login", &login);
    router.any("/logout", &logout);

    router.any("/test", &test);    

    bool isAuthorizated = false;
    bool isAdmin = false;

    auto settings = new HTTPServerSettings;
    settings.port = 8080;
    settings.bindAddresses = ["::", "127.0.0.1"];
    settings.sessionStore = new MemorySessionStore; // SESSION

    ParseConfig parseconfig = new ParseConfig();
    writeln("\nHOST: ", parseconfig.dbhost);
    db = new DBConnect(parseconfig);
    getNumberOfQID(); // questionID

    writeln("--------sending data---------");

    listenHTTP(settings, router);
    runEventLoop();
}

void accControl(HTTPServerRequest req, HTTPServerResponse res)
{
    res.headers["Access-Control-Allow-Origin"] = "*";
}

AuthInfo _auth;


void adminpage(HTTPServerRequest req, HTTPServerResponse res)
{
    if (req.session)
    {
        serveStaticFile(roothtml ~ "admin\\stat.html")(req,res);
    }
    else
    {
        res.writeBody("Access Deny", "text/plain");
    }

}


void checkAuthorization(HTTPServerRequest req, HTTPServerResponse res)
{
    logInfo("-----checkAuthorization START-----");
    Json authJsonInfo = Json.emptyObject; // Empty JSON object
    //if user already on site
    if (req.session)
    {
        logInfo("user already have active session");
        if(_auth.isAuthorized) //only user authorizate
        {
            // Set User information
            authJsonInfo["isAuthorized"] = _auth.isAuthorized;
            authJsonInfo["username"] = _auth.user.username;
            authJsonInfo["status"] = "success";
            if(_auth.isAdmin)
            {
                authJsonInfo["isAdmin"] = true; // set isAdminField
                res.writeJsonBody(authJsonInfo);
            }

            res.writeJsonBody(authJsonInfo);
            writeln(to!string(authJsonInfo));
        }

    }
    // Login infor we should check only with /login here
    else
    {
        authJsonInfo["status"] = "fail"; // unauthorized user
        res.writeJsonBody(authJsonInfo);
    }
    logInfo("-----checkAuthorization END-------");


}


void action(HTTPServerRequest req, HTTPServerResponse res)
{
    // data-stamp for every request
    DateTime currentdt = cast(DateTime)(Clock.currTime()); // It's better to declarate globally
    string datestamp = currentdt.toISOExtString;
   
    // how get string from POST request here. And how get JSON object, if server send it.
    //Json my = req.json;
    Json results;
    try
    {
        results = req.json;
    }
    catch (Exception e)
    {
        writeln("Can't parse incoming JSON string");
        writeln(e.msg);
    }
    //writeln(result["QID"]);
    writeln(results);
    //writeln(results["MaxArea"]);
    //writeln(to!string(results).lastIndexOf("MaxArea"));

    // looking MinArea and MaxArea section
    string MinArea;
    string MaxArea;
    foreach(section;results)
    {
        if(to!string(section).canFind("MinArea"))
        {
            writeln("MinArea: ", section["MinArea"].to!string);
            MinArea = section["MinArea"].to!string;
        }

        if(to!string(section).canFind("MaxArea"))
        {
            writeln("MaxArea: ", section["MaxArea"].to!string);
            MaxArea = section["MaxArea"].to!string;
        }
    }

    try
    {
        //Area Data would have QID = 100
        string result_ = ("INSERT INTO otest.mytest (`MyDate`, `QID`, `MinArea`, `MaxArea`) VALUES (" ~"'" ~ datestamp ~ "', " ~ "100" ~ "," ~ MinArea ~ "," ~ MaxArea ~");");
        db.stmt.executeUpdate(result_);
    }

    catch(Exception e) 
    {
        writeln("Can't insert MinArea and MaxArea");
        writeln(e.msg);
    }   

    foreach (result; results)
    {
        //writeln(_key);
        foreach(_k; result)
        {
            // _rk -- проверяем строку, но потом если в этой строке есть вхождение,
            // то смотрим уже _k так как это JSON

            string _rk = to!string(_k);
            if (_rk.canFind("QID"))
            {
                try
                {
                    string result = ("INSERT INTO otest.mytest (`MyDate`, `QID`, `AID`) VALUES (" ~"'" ~ datestamp ~ "', " ~ to!string(_k["QID"]) ~ "," ~ to!string(_k["AID"]) ~ ");");
                    db.stmt.executeUpdate(result);     
                }

                catch (Exception e)
                {
                    writeln("Can't insert in DB", e.msg);
                }
            }


        }
    }

}

//we need to get total number of QID that storage in DB
int [] getNumberOfQID()
{
    // чтобы минимальная и максимальная площадь вставлялась в БД один раз мы ей идентификатор 100 присвоили, и выборку по нему
    // лучше сделать потом 
    auto rs = db.stmt.executeQuery("SELECT DISTINCT QID FROM otest.mytest WHERE QID != 100");
    int [] result;
    while (rs.next())
    {
        result ~= to!int(rs.getString(1));
    }
    //writeln("==> ", result);
    return result;
}

void statistic(HTTPServerRequest req, HTTPServerResponse res)
{
    writeln("--------stat-from-site--------");
    writeln(req.json);
    writeln("--------stat-from-site--------");
    res.writeVoidBody;
}



void test(HTTPServerRequest req, HTTPServerResponse res)
{
    if (req.session)
        res.writeBody("Hello, World!", "text/plain");
}


void login(HTTPServerRequest req, HTTPServerResponse res)
{
    Json request = req.json;
    //writeln(to!string(request["username"]));
    try
    {
        string query_string = (`SELECT user, password FROM otest.myusers where user = ` ~ `'` ~ request["username"].to!string ~ `';`);
        auto rs = db.stmt.executeQuery(query_string);

        string dbpassword;
        string dbuser;

        Json answerJSON = Json.emptyObject; // response

        //writeln("rs.next() --> ", rs.next());
        /*
        if(!rs.next()) // user do not exists in DB
        {
            answerJSON["status"] = "userDoNotExists"; // user exists in DB, password NO
            answerJSON["isAuthorized"] = false;
            logInfo("-------------------------------------------------------------------------------");
            logInfo(answerJSON.toString);
            logInfo("-------------------------------------------------------------------------------");                              
            logWarn("User: %s DO NOT exists in DB!", request["username"]); //getting username from request    
        }   
        writeln(query_string);      
        */
        // ISSUE: return false if DB have ONE element with same name!
        if (rs.next()) //work only if user exists in DB
        {
            writeln("we are here");
            dbuser = rs.getString(1);
            dbpassword = rs.getString(2);    
            
            if (dbuser == request["username"].to!string && dbpassword != request["password"].to!string)
            {
                ////////IF WRONG PASSWORD///////////
                    answerJSON["status"] = "wrongPassord"; // user exists in DB, password NO
                    answerJSON["isAuthorized"] = false;
                    logInfo("-------------------------------------------------------------------------------");
                    logInfo(answerJSON.toString);
                    logInfo("-------------------------------------------------------------------------------");                              
                    logWarn("WRONG password for USER: %s", request["username"]); //getting username from request    
            }


            if (dbuser == request["username"].to!string && dbpassword == request["password"].to!string)
            {
                ////////ALL RIGHT///////////
                 logInfo("DB --> DBUser: %s DBPassword: %s", dbuser, dbpassword);
                 
                 if (!req.session) //if no session start one
                    {
                        req.session = res.startSession();
                        /* we should set this fields: 
                            _auth.isAdmin 
                            _auth.user.username 
                           to get /checkAuthorization work! */
                        _auth.isAuthorized = true; 
                        if(dbuser == "admin") // admin name hardcoded
                        {
                           _auth.isAdmin = true; 
                           _auth.user.username = "admin"; 
                           //req.session.set("username", "admin"); //ditto
                           req.session.set!string("username", "admin");

                           answerJSON["status"] = "success";
                           answerJSON["isAuthorized"] = true;
                           answerJSON["username"] = dbuser; // admin!
                           answerJSON["isAdmin"] = true;

                           res.writeJsonBody(answerJSON);
                           logInfo("-------------------------------------------------------------------------------");
                           logInfo(answerJSON.toString);
                           logInfo("-------------------------------------------------------------------------------");
                           logInfo("Admin session for user: %s started", dbuser);
                        }
                        if(dbuser != "admin") // start user session
                        {
                            req.session.set("username", dbuser); //set current username in parameter of session name
                            _auth.user.username = dbuser; //set field

                           answerJSON["status"] = "success";
                           answerJSON["isAuthorized"] = true;
                           answerJSON["username"] = dbuser; // admin!
                           answerJSON["isAdmin"] = false;

                           res.writeJsonBody(answerJSON);
                           logInfo("-------------------------------------------------------------------------------");
                           logInfo(answerJSON.toString);
                           logInfo("-------------------------------------------------------------------------------");
                           logInfo("User session for user: %s started", dbuser);
                        }

                    }
                   
            }

           
        }

        else
        {
            logInfo("User: %s do not exists in DB", dbuser);
            answerJSON["status"] = "unknownUserName"; // user exists in DB, password NO
            answerJSON["isAuthorized"] = false;
            logInfo("-------------------------------------------------------------------------------");
            logInfo(answerJSON.toString);
            logInfo("-------------------------------------------------------------------------------");                              
            logWarn("User %s DO NOT exist in DB", request["username"]); //getting username from request    
        }

    }

    catch(Exception e)
    {
        writeln("Can't process select from DB otest.myusers");
        writeln(e.msg);
        writeln("-------");
    }

   

}


void logout(HTTPServerRequest req, HTTPServerResponse res)
{
    if (req.session)
    {
        res.terminateSession();
        res.redirect("/");
    }
}
