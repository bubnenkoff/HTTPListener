module users;

struct AuthInfo
{
    User user; //User structure
    bool isAuthorizated;
    bool isAdmin;

    struct User 
	{
		int id;
		string name;
		string organization;
		string email;
	}
}

