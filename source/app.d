import vibe.d;
import std.stdio;
import std.conv;
import std.algorithm;

import ddbc.all;
import parseconfig;
import dbconnect;

DBConnect db;

void main()
{

    auto router = new URLRouter;
    router.get("*", serveStaticFiles("D:\\code\\onlineTest\\"));

    router.any("*", &accControl);
    router.any("/my", &action);
    router.any("/stat", &statistic);
    router.any("/login", &login);

    auto settings = new HTTPServerSettings;
    settings.port = 8080;
    settings.bindAddresses = ["::", "127.0.0.1"];

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



void action(HTTPServerRequest req, HTTPServerResponse res)
{
    // how get string from POST request here. And how get JSON object, if server send it.
    //Json my = req.json;
    Json results = req.json;
    //writeln(result["QID"]);
    writeln(results);

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
                    string result = ("INSERT INTO otest.mytest (`QID`, `AID`) VALUES (" ~ to!string(_k["QID"]) ~ "," ~ to!string(_k["AID"]) ~ ");");
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
void getNumberOfQID()
{
    auto rs = db.stmt.executeQuery("SELECT DISTINCT QID FROM otest.mytest");
    int [] result;
    while (rs.next())
    {
        result ~= to!int(rs.getString(1));
    }
    writeln("==> ", result);
}

void statistic(HTTPServerRequest req, HTTPServerResponse res)
{
    auto rs = db.stmt.executeQuery("SELECT AID FROM otest.mytest WHERE QID=1");
    int [] result;
    while (rs.next())
    {
        result ~= to!int(rs.getString(1));
    }
    res.writeBody(to!string(result));

}


void login(HTTPServerRequest req, HTTPServerResponse res)
{
    auto rs = db.stmt.executeQuery(`SELECT password FROM otest.myusers where user LIKE "%admin%"`);
    bool isUserExists = false;

    Json request = req.json;
    writeln(request["password"]);


    string result;
    while (rs.next())
    {
        result = rs.getString(1);
        //hardcoded!!!!
        if(result == "123")
            isUserExists = true;
        else
            isUserExists = false;
    }
    if(isUserExists)
        writeln("userexists");
    res.writeBody(to!string(result));

}