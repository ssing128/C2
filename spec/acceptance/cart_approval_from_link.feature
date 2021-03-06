Feature: Approving a cart from approval link
  Background:
    Given a cart '109876'

    And the cart has an approval for 'supervisor1@test.gov'
    And the cart has an approval for 'supervisor2@test.gov'
    And the cart has an approval for 'supervisor3@test.gov'

  Scenario: Approving with a valid token
    Given the user is 'supervisor1@test.gov'
    And a valid token
    When I go to the approval_response page with token
    Then I should see alert text 'You have approved Cart #109876.'
    And I should see 'Request approved by'
    And I should see 'Waiting for approval from'

    Given the user is 'supervisor2@test.gov'
    And a valid token
    When I go to the approval_response page with token
    Then I should see alert text 'You have approved Cart #109876.'
    And I should see 'Request approved by'
    And I should see 'Waiting for approval from'

    Given the user is 'supervisor3@test.gov'
    And a valid token
    And I go to '/'
    And I click 'Logout'
    When I go to the approval_response page with token
    Then I should see alert text 'You have approved Cart #109876.'
    And I should see 'supervisor3@test.gov'
    And I should see 'Request approved by'
    And I should not see 'Waiting for approval from'
    And I should see 'Logout'
    And I should not see 'Sign in'

    Given the user is 'user1@test.gov'
    And a valid token
    When I go to the approval_response page with token
    Then I should see alert text 'Sorry. You are not allowed to approve your own request.'

  Scenario: Cannot reuse a token
    Given the user is associated with one of the cart's approvals
    And a valid token
    And I go to '/'
    And I click 'Logout'
    When I go to the approval_response page with token
    Then I should see alert text 'You have approved Cart #109876.'
    When I go to the approval_response page with token again
    Then I should see alert text 'You have approved Cart #109876.'
    When I click 'Logout'
    And I go to the approval_response page with token again
    Then I should see alert text 'something went wrong with the token (nonexistent)'

  Scenario: Viewing existing comments
    Given the user is associated with one of the cart's approvals
    And a valid token
    When I go to the approval_response page with token
    Then I should see alert text 'You have approved Cart #109876.'
    And I should see 'No comments have been added yet'
    When I fill out 'comment_comment_text' with 'A comment on this proposal'
    And I click 'Comment' button
    Then I should not see 'No comments have been added yet'
    And I should see 'A comment on this proposal'

  Scenario: Approving with a non-existent token
    Given the user is 'supervisor1@test.gov'
    When I go to the approval_response page with invalid token '1a2b3c4d'
    Then I should see alert text 'something went wrong with the token (nonexistent)'
