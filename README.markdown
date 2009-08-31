Driver is for setting up your passenger vhosts. The original idea was created when Passenger Preference Pane was hanging on my Snow Leopard machine. Apparently this is no longer the case with the latest passenger pane build. This project still lives, as there is room to make it Linux-compatible.

## Install

First off you're going to need to install the `sinatra` and `ghost` gems: `sudo gem install sinatra ghost` will do that for you. Sinatra is the framework the application uses for hosting the app and Ghost is the utility it uses for adding hosts to point at 127.0.0.1.

Next, run `sudo rake install` which should load up `http://driver.local` for you.


## Why is it broken?

Because it's currently in beta. If you'd like to beta test it, just follow the install instructions above. If you find something that is broken please file an issue.

## Known Bugs

When you're streaming music from your Mac machine to an Airport and you call a `ghost` command such as `rm` or `add` it will pause iTunes. Adding, modifying and deleting hosts does this. I don't know why. 