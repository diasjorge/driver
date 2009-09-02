function selected(element, name) {
  $('#hosts li').removeClass('selected');
  $.get('/edit/' + name, function(data){
    $('#config').html(data);
    $('#' + element.id).addClass('selected');
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
  $("#loading").show();
  $.get('/new', function(data){
    $('#config').html(data);
  });
  $("#loading").hide();
}

function restart() {
  $("#loading").show();
  $.get('/restart', function(data) {
    $('config').html(data);
  });
  $("#loading").hide();
}


// actions!

function update() {
  $("#loading").show();
  post = $('#config_form').serialize();
  $.post('/update', post, function(data){
    display_message(data);
  });
  $("#loading").hide();
}

function create() {
  $("#loading").show();
  post = $('#config_form').serialize();
  $.post('/create', post, function(data){
    $.get('/hosts', function(hosts) {
      $('#hosts').html(hosts);
      $('#config').html("");
      $('#folders').hide();
    });
    display_message(data);
  });
  $("#loading").hide();
};

function remove(name) {
  $("#loading").show();
  $.post('/delete?name=' + name, function(data) {
    display_message(data);
    $.get('/hosts', function(hosts) {
      $('#hosts').html(hosts);
      $('#config').html("");
      $('#folders').hide();
    });
  });
  $("#loading").hide();
}

// For loading the folder selector
function folder_selector(directory) {
  $("#loading").show();
  $("#DocumentRoot").click(function () {
    $('#folders').show();
  });
  $.get('/folders' + directory, function(data){
    $('#folders').html(data);
  });
  $("#loading").hide();
}

// For navigations
function enter_folder(directory) {
  $("#loading").show();
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
  parts = $('#DocumentRoot').val().split("/");
  
  // To automatically fill out the ServerName.
  second_to_last_part = parts[parts.length-2];
  $('#ServerName').val(second_to_last_part + '.local');


  // To detect if it is public, then "raise" an error if it is.
  last_part = parts[parts.length-1];  
  
  error_element = $('#errors_for_DocumentRoot');
  if (last_part != "public") {
    error_element.html("The path does not end in public. <br> Passenger requires DocumentRoot to be a path to a public folder.");
    error_element.show();
  }
  else {
    error_element.hide();
  }
  $("#loading").hide();
}