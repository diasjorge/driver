function selected(element, name) {
  $('#hosts li').removeClass('selected');
  $('#' + element.id).addClass('selected');
  $.get('/edit/' + name, function(data){
    $('#config').html(data);
  });
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
    $('#message').html("Update successful!");
  });
}

function create() {
  post = $('#config_form').serialize();
  $.post('/create', post, function(data){
    $('#message').html("Passenger created!");
  });
  
  $.post('/create', post, function(data){
    $.get('/hosts', function(hosts) {
      $('#hosts').html(hosts);
    });
    $('#message').html("Passenger created!");
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
    current_path = enter_path.join("/");
    $.get('/folders' + current_path, function(data){
      $('#folders').html(data);
    });
  }
  else {
    current_path = $('#current_path').val();
    $.get('/folders' + current_path + '/' + directory, function(data){
      $('#folders').html(data);
    });
  }
}

function selected_path(directory) {
  if (directory != "..") {
    current_path = $('#current_path').val();
    path = current_path + '/' + directory;
  }
  else {
    path = $('#current_path').val().split("/");
    path.pop();
    path = path.join("/");
  }
  path = path.replace("//", "/");
  $('#DocumentRoot').val(path);
}