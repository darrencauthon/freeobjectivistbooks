Feature: Auto-cancel old requests

Scenario: A doner for a request could not be found in three months
  Given a request for a book was made
  And three months passed
  When requests are checked
  Then the request should be canceled
  And a notification should be sent to the user

