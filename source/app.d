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

    auto settings = new HTTPServerSettings;
    settings.port = 8080;
    settings.bindAddresses = ["::", "127.0.0.1"];

    ParseConfig parseconfig = new ParseConfig();
    db = new DBConnect(parseconfig);

    //string total_count;

    //    auto request_before = db.stmt.executeQuery("select COUNT(*) from " ~ parseconfig.dbname ~ ".mytest");
    //        while(request_before.next())
    //        {
    //            total_count = request_before.getString(1);
    //            writeln(total_count);
    //        }
  

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
                //writeln(_k["QID"]);
                string result = ("INSERT INTO otest.mytest (`QID`, `AID`) VALUES (" ~ to!string(_k["QID"]) ~ "," ~ to!string(_k["AID"]) ~ ");");
                db.stmt.executeUpdate(result);     
            }

            //writeln(_k);



        }
    }

}
