function selected(element, name) {
  $('#hosts li').removeClass('selected');
  $('#' + element.id).addClass('selected');
  $.get('/edit/' + name, function(data){
    $('#config').html(data);
  });
}

function display_message(data) {
  if (data.match(/^Error:/)) {
    $('#message').removeClass('success');
    $('#message').addClass('error');
    $('#message').html(data.split(":")[1]);
  }
  else {
    $('#message').removeClass('error');
    $('#message').addClass('success');
    $('#message').html(data);
  };
  $('#message').show();
}

// buttons!

function new_form() {
  $.get('/new', function(data){
    $('#config').html(data);
  });
}

function restart() {
  $.get('/restart', function(data) {
    $('config').html(data);
  });
}


// actions!

function update() {
  post = $('#config_form').serialize();
  $.post('/update', post, function(data){
    display_message(data);
  });
}

function create() {
  post = $('#config_form').serialize();
  $.post('/create', post, function(data){
    $.get('/hosts', function(hosts) {
      $('#hosts').html(hosts);
      $('#config').html("");
      $('#folders').hide();
    });
    display_message(data);
  });
};

function remove(name) {
  $.post('/delete?name=' + name, function(data) {
    display_message(data);
    $.get('/hosts', function(hosts) {
      $('#hosts').html(hosts);
      $('#config').html("");
      $('#folders').hide();
    });
  });
}

function folder_selector(directory) {
  $("#DocumentRoot").click(function () {
    $('#folders').show();
  });
  $.get('/folders' + directory, function(data){
    $('#folders').html(data);
  });
}

function enter_folder(directory) {
  if (directory == "..") {
    enter_path = $('#current_path').val().split("/");
    enter_path.pop();
    path = enter_path.join("/");
    $.get('/folders' + path, function(data){
      $('#folders').html(data);
    });
  }
  else {
    current_path = $('#current_path').val();
    path = current_path + '/' + directory;
    $.get('/folders' + current_path + '/' + directory, function(data){
      $('#folders').html(data);
    });
  }
  path = path.replace("//", "/");
  $('#DocumentRoot').val(path);
}