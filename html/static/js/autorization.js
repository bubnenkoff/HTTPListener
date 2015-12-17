// app.directive('ngAuthMenu', function() {
//     return {
//         templateUrl: 'template/auth-menu.html',
//         scope: true,
//         controller: function($scope) {},
//         link: function($scope, $element, attrs) {}
//     }
// });

app.directive('ngAuthMenu', function() {
    return {
        scope: true,
        templateUrl: 'template/auth-menu.html',
        controller: function($scope, $rootScope, $http) {

	$rootScope.isAuthorized = false;
	$rootScope.isAdmin = false;


	// Check if user authorizeted 
	$http.get('http://127.0.0.1:8080/checkAuthorization').then(function(response) {
    	console.log("Login data from Server: ", response.data);
    	// we expect: {"loginName":"user"}
    	if(response.data["status"] == "success")
    	{
	    	if (response.data["isAuthorized"] == true) // user authorized
	    	{
				$rootScope.isAuthorized = true;    		
				console.log("Login user session: ", response.data["loginName"]);
				if (response.data["loginName"] == "admin") // user logged
	    		{
					$rootScope.isAdmin = true;   					
	    		}
	    		if (response.data["loginName"] != "admin") // if not admin
	    		{
					$rootScope.isAdmin = false; 					
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