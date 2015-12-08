app.directive('ngAuthorization', function() {
    return {
     
        scope: true,
        controller: function($scope, $http) {

		$scope.showLoginBar = true;


	// Check if user authorizeted 
	$http.get('http://127.0.0.1:8080/checkAuthorization').then(function(response) {
    	console.log("---->", response.data);
    	if (response.data == "onSite") // user logged
      {
			 $scope.showLoginBar = false;    		

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

				console.log(authdata);
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