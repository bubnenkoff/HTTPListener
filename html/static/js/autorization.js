app.directive('ngAuthMenu', function() {
    return {
        templateUrl: 'template/auth-menu.html',
        scope: true,
        controller: function($scope) {},
        link: function($scope, $element, attrs) {}
    }
});

app.directive('ngAuthorization', function() {
    return {
        scope: true,
        controller: function($scope, $http) {

$scope.isAuthorized = false;
$scope.isAdmin = false;


	// Check if user authorizeted 
	$http.get('http://127.0.0.1:8080/checkAuthorization').then(function(response) {
    	console.log("Login data from Server: ", response.data);
    	// we expect: {"loginName":"user"}
    	if(response.data["status"] == "success")
    	{
	    	if (response.data["isAuthorized"] == true) // user authorized
	    	{
				$scope.isAuthorized = true;    		
				console.log("Login user session: ", response.data["loginName"]);
				if (response.data["loginName"] == "admin") // user logged
	    		{
					$scope.isAdmin = true;   					
	    		}
	    		if (response.data["loginName"] != "admin") // if not admin, so user
	    		{
					//ADD 					
	    		}
	    	}
	    	else
	    		console.log("Wrong Auth data!");
	    }

	    if(response.data["status"] == "fail")
	    {
	    	console.log("Unauthorized user");
	    }



	});		


		// send login info to server
		$scope.sendLoginInfo = function() 
			{
				authdata = JSON.stringify({'username': $scope.username, 'password' : $scope.password});
				$http({
					method: 'POST',
					url: 'http://127.0.0.1:8080/login',
					data: authdata
					
				})
					.success(function(data) {
					  location.reload();
					})

				console.log("Post Request From Login: ", authdata);
			}
			
	  // send logout
		$scope.sendLogout = function() 
			{
			  $http.get('http://127.0.0.1:8080/logout').then(function(response) {
				   $scope.showLoginBar = true;
					location.replace('/');       
			   }); 
			}
   
 
   
   
        }
    }
})