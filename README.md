===================
INFOMATION RETRIEVAL
FINAL PROJECT
Ran Galili 302976964
ran632@gmail.com
----------------------
Project was written in ruby language.

-----======== INSTALLATION ========-----
First, you'll need to download install ruby, ofcourse :)
Version 2.1.5 is recommended
You can download it from here:
https://www.ruby-lang.org/en/news/2014/11/13/ruby-2-1-5-is-released/

After ruby is installed,
In the directory of this file please execute this commands (in the following order):
```
  gem install bundler
  bundle install
  git add Gemfile Gemfile.lock
```

-----======== USAGE ========-----
The project is divided to two parts by files.
part1.rb and part2-5.rb

= Part 1: The Crawler =

Crawling movies documents from TOREC.net, and outputs metadata file ('data.csv') and movies directory with their description
Command (within this file directory):

``` ruby part1.rb ```

first, you'll be asked by the program for how many movies would like to crawl.
type number from 1 to, lets say, 8500 (num of movies in torec.net)?, and the press ENTER
The program will start crawling, it can take some time, depands of how many movies did you decided to crawl.

= Part 2-5: Search Engine =

Initialize the search engine, and initiate the User Interface for searching.
Command (within this file directory):
```
  ruby part2-5.rb
```
After initializing (takes like 10 seconds) you can start send hebrew queries.
after every query that being sent you'll be asked for how many results you would like to receive (will take the best ones relying on BM25 score)
The results output will be within this directory in 'results.txt'.
type 'bye' in order to exit.


If you have any question feel free to ask me ran632@gmail.com
