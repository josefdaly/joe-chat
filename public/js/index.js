window.onload = function(){
  (function(){
    var goToChat = function() {
      var userPath = $('#basic-url').val();
      if (userPath == "") {
        alert('You must specify a path!')
      } else {
        var path = window.location.origin + '/' + userPath;
        window.open(path);
      }
    };

    $('#create').click(function() {
      goToChat();
    });

    $('#basic-url').keypress(function(k) {
      if (k.which == 13) {  
        goToChat();
      }
    })

    var fetchAndAppendActiveRooms = function() {
      var url = window.location.origin + '/open_rooms';
      $.ajax({
        url: url,
        success: function(response) {
          $roomList = $('#active-room-list');
          $roomList.html("");
          var propertyCounter = 0;
          for (var property in response) {
            if (response.hasOwnProperty(property)) {
              propertyCounter++;
              $roomList.append("<a href='" + window.location.origin + "/" + property + "' class='list-group-item'>" + property +
                "<span class='glyphicon glyphicon-user pull-right'></span><span class='badge'>" + response[property] + "  </span></a>"
              );
            }
            if (propertyCounter > 0) {
              $('#active-room-header').show();
            }
          }
          if (propertyCounter == 0) {
            $('#active-room-header').hide();
          }
        }.bind(this)
      });
    }

    fetchAndAppendActiveRooms();
    setInterval(fetchAndAppendActiveRooms, 1500);
  })();
}
