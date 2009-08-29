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

function file_name(element) {
  alert($('#file').val());
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