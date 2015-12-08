app.controller("StatisticCtrl", function($scope, $http) 
{
  // var chartData={
  //   "type":"bar",  // Specify your chart type here.
  //   "series":[  // Insert your series data here.
  //       { "values": [35, 42, 67, 89]},
  //       { "values": [28, 40, 39, 36]}
  //   ]
  // };
  // zingchart.render({ // Render Method[3]
  //   id:'chartDiv',
  //   data:chartData,
  //   height:400,
  //   width:600
  // });

	// ditto qustion.js except path
    $scope.questions; // load questions from file
		$http.get('../js/questions-content.json').then(function(response) {
         $scope.questions =  response.data;
         // console.log(response.data);

    });


	var data_fromServer;


	 //  	$scope.stat_fromdb; // console.log do not print data becouse asynchronous request
		// $http.get('http://127.0.0.1:8080/stat').success(function(response) {
  //        $scope.stat_fromdb = response.data;

  //        	angular.forEach($scope.stat_fromdb, function(value, key) {
		// 	  console.log(key + ': ' + value);
		// 	});

		// });


/*
			$scope.stat_fromdb = null; // console.log do not print data becouse asynchronous request

			$http.get('http://127.0.0.1:8080/stat').success(function(response) {
				$scope.stat_fromdb = response.data;
				console.log(response.data);
				processStat();
			});

			function processStat() {
				angular.forEach($scope.stat_fromdb, function(value, key) {
				console.log(key + ': ' + value);
				console.log($scope.stat_fromdb);
				});
				console.log("hello");

			}
*/

/*
	// synchronous way to get data sing JQuery
	$scope.server_data = $.ajax({
	  url: 'http://127.0.0.1:8080/stat',
	  async: false,
	  dataType: 'json',
	  success: function (response) {
	    return response.responseText;
	  }
	});

	console.log($scope.server_data.responseText);


	// angular.forEach($scope.server_data, function(value) {
	//   console.log(value);
	// });
*/


////////////////////////////////////////////////////////////////////////////////////////
$scope.chart1 = function() 
    {	
			var getData = function (callMeWhenDataReady) {
			$http.get('http://127.0.0.1:8080/stat1').success(function(response) {
			         //var data = response.data; // respose не имеет свойства data
			       //  var data = JSON.stringify(response); // respose не имеет свойства data
			         var data = response; // respose не имеет свойства data
			         // console.log(JSON.stringify(response));
			         // console.log(data);
			         // передаем данные во внешний callback
			         callMeWhenDataReady(data);
			});
			};


			// Ответ в формате строки (JSON)	
			getData(function(data) { 
				console.log(data);

				var x = data;//.replace("[","").replace("]","").replace('"', "").split(',');
				// var x = data.replace("[","").replace("]","").replace('"', "").split(',');
				console.log(x);


         		  var chartData={
			      // "type":"bar",  // Specify your chart type here.
			      "type":"bar",  // Specify your chart type here.
			      "scale-x":{
           			 "labels": ["Федеральные органы власти", "Региональные органы", "Местные органы управления", "Некоммерческие организации", "Частное лицо",  "Другое"]
      				  },
			      "series":[  // Insert your series data here.
			          // { "values": response.data},
			          // { "values": response.data}
			          { 
			          	"values": x
			      	  }
			      ]
			    };
			    zingchart.render({ // Render Method[3]
			      id:'chartDiv1',
			      data:chartData,
			      height:400,
			      width:"100%"
			    });	

			} );
	}
//////////////////////////////////////////////////////////////////			


////////////////////////////////////////////////////////////////////////////////////////

$scope.chart2 = function() 
    {
			var getData2 = function (callMeWhenDataReady) {
			$http.get('http://127.0.0.1:8080/stat2').success(function(response) {
			         //var data = response.data; // respose не имеет свойства data
			       //  var data = JSON.stringify(response); // respose не имеет свойства data
			         var data2 = response; // respose не имеет свойства data
			         // console.log(JSON.stringify(response));
			         // console.log(data);
			         // передаем данные во внешний callback
			         callMeWhenDataReady(data2);
			});
			};


			// Ответ в формате строки (JSON)	
			getData2(function(data2) { 
				console.log(data2);

				var x2 = data2;//.replace("[","").replace("]","").replace('"', "").split(',');
				// var x = data.replace("[","").replace("]","").replace('"', "").split(',');
				console.log(x2);


         		  var chartData2={
			      // "type":"bar",  // Specify your chart type here.
			      "type":"bar",  // Specify your chart type here.
			      "scale-x":{
           			 "labels": ["Сельское хозяйство", "Лесное хозяйство", "Землепользование"]
      				  },
			      "series":[  // Insert your series data here.
			          // { "values": response.data},
			          // { "values": response.data}
			          { 
			          	"values": x2
			      	  }
			      ]
			    };
			    zingchart.render({ // Render Method[3]
			      id:'chartDiv2',
			      data:chartData2,
			      height:400,
			      width:"100%"
			    });	

			} );
	}		
//////////////////////////////////////////////////////////////////	

////////////////////////////////////////////////////////////////////////////////////////

$scope.chart3 = function() 
    {
			var getData3 = function (callMeWhenDataReady) {
			$http.get('http://127.0.0.1:8080/stat3').success(function(response) {
			         //var data = response.data; // respose не имеет свойства data
			       //  var data = JSON.stringify(response); // respose не имеет свойства data
			         var data3 = response; // respose не имеет свойства data
			         // console.log(JSON.stringify(response));
			         // console.log(data);
			         // передаем данные во внешний callback
			         callMeWhenDataReady(data3);
			});
			};


			// Ответ в формате строки (JSON)	
			getData3(function(data3) { 
				console.log(data3);

				var x3 = data3;//.replace("[","").replace("]","").replace('"', "").split(',');
				// var x = data.replace("[","").replace("]","").replace('"', "").split(',');
				console.log(x3);


         		  var chartData3={
			      // "type":"bar",  // Specify your chart type here.
			         "type":"range",
			        "series":[
							    {"values": [[10,90],[20,90],[30,90],[40,90],[11,60],[5,40],[40,90],[40,90],]}

							    // {"values":[ [15,30],
							    //             [20,40],
							    //             [16,35],
							    //             [21,30],
							    //             [25,45],
							    //             [18,27],
							    //             [23,35],
							    //             [29,39],
							    //             [27,30],
							    //             [19,34]
							    //             ]}
			      			]


			      // // "type":"bar",  // Specify your chart type here.
			      // "type":"bar",  // Specify your chart type here.
			      // "series":[  // Insert your series data here.
			      //     // { "values": response.data},
			      //     // { "values": response.data}
			      //     { 
			      //     	"values": [28, 40, 39, 36]
			      // 	  }
			      // ]


			    };



			    zingchart.render({ // Render Method[3]
			      id:'chartDiv3',
			      data:chartData3,
			      height:400,
			      width:"100%"
			    });	

			} );
	}		
//////////////////////////////////////////////////////////////////	












/*
		y = fetch('http://127.0.0.1:8080/stat')  
		  .then(  
		    function(response) {  
		      if (response.status !== 200) {  
		        console.log('Looks like there was a problem. Status Code: ' +  
		          response.status);  
		        return response.data;  
		      }

		      // Examine the text in the response  
		      response.json().then(function(data) {  
		        console.log(data);  
		      });  
		    }  
		  )  
		  .catch(function(err) {  
		    console.log('Fetch Error :-S', err);  
		  });    	 
		  console.log(y);  
*/


/////////////////
/// 
/*
		$http.get('http://127.0.0.1:8080/stat1').then(function(response) {
         // console.log(response.data);
         		  var chartData={
			      // "type":"bar",  // Specify your chart type here.
			      "type":"bar",  // Specify your chart type here.
			      "scale-x":{
           			 "labels": ["Федеральные органы исполнительной власти", "Региональные органы", "Местные административные органы управления", "Некоммерческие организации", "Частное лицо",  "Другое"]
      				  },
			      "series":[  // Insert your series data here.
			          // { "values": response.data},
			          // { "values": response.data}
			          { "values": response.data}
			      ]
			    };
			    zingchart.render({ // Render Method[3]
			      id:'chartDiv1',
			      data:chartData,
			      height:400,
			      width:"100%"
			    });	

   		 });

*/

/*
	    $scope.questions2; // load questions from file
		$http.get('http://127.0.0.1:8080/stat2').then(function(response) {
         $scope.questions2 =  response.data;
         // console.log(response.data);
         		  var chartData={
			      // "type":"bar",  // Specify your chart type here.
			      "type":"bar",  // Specify your chart type here.
			      "scale-x":{
           			 "labels": ["Сельское хозяйство", "Лесное хозяйство", "Землепользование"]
      				  },
			      "series":[  // Insert your series data here.
			          // { "values": response.data},
			          // { "values": response.data}
			          { "values": response.data}
			      ]
			    };
			    zingchart.render({ // Render Method[3]
			      id:'chartDiv2',
			      data:chartData,
			      height:400,
			      width:"100%"
			    });	

   		 });

*/


		console.log(data_fromServer);

		// same as in question js logout
    $scope.sendLogout = function() 
        {
          $http.get('http://127.0.0.1:8080/logout').then(function(response) {
               $scope.showLoginBar = true;       
				location.replace('/');      
           }); 
        }

});
