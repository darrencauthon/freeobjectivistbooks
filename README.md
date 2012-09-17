# Free Objectivist Books

This is the code for http://freeobjectivistbooks.org.

The purpose of this site is to match up students who want to read Objectivist books with donors who are willing to send them. The goal is to get more students reading Ayn Rand.

Free Objectivist Books is a community project. It lives at: https://github.com/jasoncrawford/freeobjectivistbooks

This README is a guide for developers who want to help out.

## How to help

1. Read this README
2. Fork the repo
3. [Find an issue you want to tackle](https://github.com/jasoncrawford/freeobjectivistbooks/issues), or add one of your own
4. Assign the issue to yourself
5. Code it up, including tests
6. Send me a pull request
7. I'll review it, pull it, and deploy
9. Go to step 3

## A few practical tips

* Make sure you're using Ruby 1.9.2 (on a Mac, you may have 1.8 installed by default).
* The best way to run the app locally is using Foreman: `foreman start`. That runs both the server and a delayed_jobs worker thread. (This will run the app at port 5000, not 3000 as is the default when you run `rails server`.)
* Documentation is available (via RDoc); find it in doc/app/index.html and regenerate it with `rake doc:app`.
* We use Delayed::Jobs for long-running tasks. Worth reading up on if you're touching notifications/reminders.
* We're using the 960 Grid System: http://960.gs/. You may want to familiarize yourself with it if you're touching views.

## Developer guidelines

* Use GitHub to manage workflow: issues, pull requests, etc.
* Follow Ruby & Rails conventions.
* Develop for Ruby 1.9.2 (it's what we use in production on Heroku).
* Write [fat models and skinny controllers](http://weblog.jamisbuck.org/2006/10/18/skinny-controller-fat-model).
* Write tests for everything. We should be able to deploy with confidence without manual regression testing. Run the tests (with `rake test`) and make sure they're all green before submitting a pull request.
* Write brief class-level and (where appropriate) method-level comments suitable for RDoc.
* Create custom Rake tasks for any management commands, including any scheduled tasks.
* Use delayed jobs for any long-running task that can be done in the background.
* [Long-running scheduled tasks should also be put in the delayed job queue.](https://devcenter.heroku.com/articles/scheduler#longrunning-jobs)
* Do your best work, and have fun!
