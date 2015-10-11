window.onload = function(){
  (function(){
    $('#create').click(function() {
      var userPath = $('#basic-url').val();
      if (userPath == "") {
        alert('You must specify a path!')
      } else {
        var path = window.location.origin + '/' + userPath;
        window.location.replace(path);
      }
    });

    var fetchAndAppendActiveRooms = function() {
      var url = window.location.origin + '/open_rooms';
      $.ajax({
        url: url,
        success: function(response) {
          $roomList = $('#active-room-list');
          $roomList.html("");
          for (var property in response) {
            if (response.hasOwnProperty(property)) {
              debugger
              $roomList.append("<a href='" + window.location.origin + "/" + property + "' class='list-group-item'>" + property +
                "<span class='glyphicon glyphicon-user pull-right'></span><span class='badge'>" + response[property] + "  </span></a>"
              );
            }
          }
        }.bind(this)
      });
    }

    fetchAndAppendActiveRooms();
    setInterval(fetchAndAppendActiveRooms, 1500);
  })();
}
