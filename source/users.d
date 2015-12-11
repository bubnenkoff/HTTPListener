module users;

struct AuthInfo
{
    User user; //User structure
    bool isAuthorized;
    bool isAdmin;

    struct User 
	{
		int id;
		string username;
		string organization;
		string email;
	}
}

