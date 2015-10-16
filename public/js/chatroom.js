window.onload = function(){
  (function(){
    var date;
    var getAndSetTime = function() {
      date = new Date();
      $('#hours').html(date.getHours() % 12);
      var minutes = date.getMinutes();
      if (minutes < 10) {
        minutes = '0' + minutes;
      }
      $('#minutes').html(minutes);
    };

    getAndSetTime();
    setInterval(getAndSetTime, 30000);

    $('#handle').keypress(function(k) {
      if (k.which == 13) {
        $('#input').focus();
      }
    });

    $('#input').keypress(function(e) {
      if (e.which == 13) {
        $('#input').submit();
      }
    }.bind(this))

    $(function() {
      $("#chat-window").draggable();
    });

    var inFocus;
    var unseenNotifications = 0;
    $(window).focus(function() {
      inFocus = true;
      unseenNotifications = 0;
      $('title').html("Joe Chat")
    });

    $(window).blur(function() {
      inFocus = false;
    });

    var show = function($el){
      return function(msg, sender){
        $el.append("<li class='chat-body'><strong>" +
          sender + ": </strong>" + msg + "</li>");
      }
    }($("#msgs"));

    var ws = new WebSocket('ws://' + window.location.host + window.location.pathname);
    ws.onopen = function() {
      show('websocket opened', 'AI Overlord');
    };
    ws.onclose = function() {
      show('websocket closed', 'AI Overlord');
    };
    ws.onmessage = function(m) {
      var msg = JSON.parse(m.data)
      if (msg['type'] == 'group-message'){
        show(msg.content, msg.sender);
        $(".chat").animate({ scrollTop: $('.chat')[0].scrollHeight }, "slow");
        if (inFocus == false) {
          unseenNotifications++;
          $("title").html("(" + unseenNotifications + ") Joe Chat");
        }
      } else if (msg['type'] == 'status-update') {
        var numUsers = msg.num_users;
        $('#user-count').html(numUsers);
      }
    };

    setInterval(function(){
      ws.send(JSON.stringify({ 'type': 'update-request' }));
    }.bind(this), 500)

    var sender = function(f){
      var input = document.getElementById('input');

      f.onsubmit = function(){
        ws.send(
          JSON.stringify(
            {
              'type': 'group-message',
              'content': input.value,
              'sender': document.getElementById('handle').value
            }
          )
        );
        setTimeout(function(){$('#input').val('');}.bind(this), 5);
        return false;
      }
    }(document.getElementById('form'));
  })();
}
