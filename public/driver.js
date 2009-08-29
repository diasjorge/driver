function selected(element, name) {
  $('#' + element.id).wrap("<strong></strong>");
  $.get('/edit/' + name, function(data){
    $('#config').html(data);
  });
}

function new_form() {
  $.get('/new', function(data){
    $('#config').html(data);
  });
}

function update() {
  post = $('#config_form').serialize();
  $.post('/update', post, function(data){
    $('#message').html(data);
  });
}

function create() {
  post = $('#config_form').serialize();
  $.post('/create', post, function(data){
    $('#message').html(data);
  });
}

function folder_selector(directory) {
  $.get('/folders' + directory, function(data){
    $('#folders').html(data);
  });
}

function enter_folder(directory) {
  if (directory == "..") {
    path = $('#current_path').val().split("/");
    path.pop();
    current_path = path.join("/");
  }
  else {
    current_path = $('#current_path').val();
  }
  
  $.get('/folders' + current_path + '/' + directory, function(data){
    $('#folders').html(data);
  });
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