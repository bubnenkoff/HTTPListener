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

DBConnect db;

bool isAuthorizated;

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
    router.get("/", serveStaticFiles(roothtml ~ "pages\\"));    
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
    //if user already on site
    if (req.session)
    {
        res.writeBody("onSite"); // autorizated
        res.redirect("/");

        writeln("Is Admin --> ", isAdmin);
    }

    else
        res.writeVoidBody();
        res.statusCode = 204; // all good nothing to return

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
   string result_json;

    foreach(i, QID; getNumberOfQID) // now we need iterate all QID
    {

        i++;
        string query_string = "SELECT AID FROM otest.mytest WHERE QID=" ~ to!string(QID);
        auto rs = db.stmt.executeQuery(query_string);
        int [] result;
        while (rs.next())
        {
            result ~= to!int(rs.getString(1));
            //writeln(result);
        }

        string single_QID = "{" ~ `"` ~ to!string(QID) ~ `":` ~ to!string(result) ~ "}";
       // writeln(single_QID);
        result_json ~= single_QID ~ ",";
        //writeln(result_json);
        //writeln;
        
        string result_json1;
        result_json1 ~= ("[" ~ result_json ~ "]").replace("},]","}]");

        // _Very_ dirty hack to send JSON array of QID and their result at _last_ iteration! 
        if((i == getNumberOfQID.length - 1))
        {
            writeln(result_json1);
            res.writeBody(to!string(result_json1));
        }
        
    } 

}




void test(HTTPServerRequest req, HTTPServerResponse res)
{
    if (req.session)
        res.writeBody("Hello, World!", "text/plain");
}

bool checkUserGroup()
{
    return false;
}

string login(HTTPServerRequest req, HTTPServerResponse res)
{
    Json request = req.json;
    //writeln(to!string(request["username"]));
    writeln("Login section");

    try
    {
        string query_string = (`SELECT user, password FROM otest.myusers where user LIKE ` ~ `'%` ~ request["username"].to!string ~ `%';`);
        auto rs = db.stmt.executeQuery(query_string);
    
        string dbpassword;
        string dbuser;
        
        while (rs.next())
        {
            dbuser = rs.getString(1);
            dbpassword = rs.getString(2);
            //writeln("dbpassword: ", dbpassword);
            //writeln("req pass: ", request["password"].to!string);

            if (dbuser == request["username"].to!string && dbpassword == request["password"].to!string)
            {
                writeln("User exist in DB: ", request["username"].to!string);
                 //if no session start one
                 if (!req.session) 
                    {
                        req.session = res.startSession();
                        res.redirect("/");

                        if(dbuser == "admin") // admin name hardcoded
                        {
                            return "admin";
                        }

                        isAuthorizated = true;


                    }
                 return "user";       
            }

            else
            {
                writeln("you are not admin");
                isAuthorizated = false;
                //res.redirect("/");
            }

        }
         res.redirect("/");

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
