== README

This application serves as helping tool for log parsing.



To run this application you need: <br />
ruby (used version): 2.1.2 -> <em>sudo apt-get install ruby</em> <br />
rails (used version): 4.2.6 -> <em>sudo apt-get install rails</em> <br />
You can either download used versions or change them in <em>Gemfile</em> <br />
postgreSQL <br />
gem 'bundler' -> installed with <em>gem install bundler</em> <br />

1. clone current repository or download it in form of a .zip file.
2. go to the root direcotry and download all dependencies (possible with command): <br />
   <em>bundle install</em>
3. create database: <br />
   <em>rake db:create</em>
4. setup database: <br />
   <em>rake db:setup</em>
5. run the server: <br />
   <em>rails s</em>
<br />
default port is 3000.
