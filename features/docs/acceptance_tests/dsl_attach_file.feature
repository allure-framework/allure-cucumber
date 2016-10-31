@feature1
@dsl_attach_file
Feature: "AllureCucumber::DSL#attach_file' method should work correctly in all possible cases

  In order to be sure that attaching a file works correctly
  I want to verify all possible ways how a file can be attached to Allure report

  Variations how a file can be attached:
      by place of 'attach_file' code: [
        in a step of Scenario,
        in a step of Scenario Outline,
        in a step of Background,
        in hook 'Before',
        in hook 'After',
        in Around if call 'attach_file' before block.call,
        in Around if call 'attach_file' after block.call
      ]

      by using '--expand': [
        expand yes,
        expand no
      ]

      by attach_file's step position: [
        first step ,
        second step
      ]

  Generated combinations for testing using 'pairwise' Ruby gem:

    | by attach_file's step position | by place of 'attach_file' code                    | by using '--expand' |
    | first step                     | in a step of Scenario                             | expand yes          | @scenario_pw_2_01
    | first step                     | in a step of Scenario Outline                     | expand no           | @scenario_pw_2_02
    | first step                     | in a step of Background                           | expand no           | @scenario_pw_2_03
    | first step                     | in hook 'Before'                                  | expand no           | @scenario_pw_2_04
    | first step                     | in hook 'After'                                   | expand no           | @scenario_pw_2_05   
    | first step                     | in Around if call 'attach_file' before block.call | expand no           | @scenario_pw_2_06   
    | first step                     | in Around if call 'attach_file' after block.call  | expand no           | @scenario_pw_2_07   
    | second step                    | in a step of Scenario                             | expand no           | @scenario_pw_2_08  
    | second step                    | in a step of Scenario Outline                     | expand yes          | @scenario_pw_2_09   
    | second step                    | in a step of Background                           | expand yes          | @scenario_pw_2_10  
    | second step                    | in hook 'Before'                                  | expand yes          | @scenario_pw_2_11  
    | second step                    | in hook 'After'                                   | expand yes          | @scenario_pw_2_12  
    | second step                    | in Around if call 'attach_file' before block.call | expand yes          | @scenario_pw_2_13  
    | second step                    | in Around if call 'attach_file' after block.call  | expand yes          | @scenario_pw_2_14  



  Background:
    Given I use a fixture named "minimal_cucumber_app"
    Given a file named "features/lib/step_definitions/steps.rb" with:
    """
    When /^I attach file$/ do
      File.write('temp_file', 'some_text')
      file = File.open('temp_file')
      file.close
      attach_file('some_title', file)
    end

    Given /^This step is passed$/ do
      puts 'This is a message from passed step'
    end

    """

    And a file named "features/lib/support/env.rb" with:
    """
    require 'bundler/setup'
    require 'allure-cucumber'

    AllureCucumber.configure do |c|
       c.output_dir = "reports"
    end

    World(AllureCucumber::DSL)

    """

  @scenario1
  Scenario: Should not raise error message if "--format AllureCucumber::Formatter --out reports/allure-report/ --format pretty" parameters were not passed. BUT DOES IT
    Given a file named "features/docs/attach_file.feature" with:
    """
      Feature: title
        Scenario: attach_file
          When I attach file
    """

    When I run `cucumber --expand`
    Then the output from "cucumber --expand" should contain "1 scenario (1 passed)"
    And the exit status should be 0

  @scenario2
  @scenario_pw_2_01
  Scenario: Should not put 'Cannot attach...' message  if "--format AllureCucumber::Formatter --out reports/allure-report/ --format pretty" parameter was specified. BUT DOES IT
    Given a file named "features/docs/attach_file.feature" with:
    """
      Feature: title
        Scenario: attach_file
          When I attach file
    """
    When I run `cucumber --expand --format AllureCucumber::Formatter --out reports/allure-report/ --format pretty`
    Then the output from "cucumber --expand --format AllureCucumber::Formatter --out reports/allure-report/ --format pretty" should not contain "Cannot attach"
    Then the output from "cucumber --expand --format AllureCucumber::Formatter --out reports/allure-report/ --format pretty" should contain "1 scenario (1 passed)"
    And the exit status should be 0


  # This scenario illustrates an incorrect behaviour for scenario '@scenario2'.
  @scenario3
  @scenario_pw_2_08
  Scenario: Should not be difference how much steps was run before attaching file. BUT THE DIFFERENCE IS PRESENT
    Given a file named "features/docs/attach_file.feature" with:
    """
      Feature: title
        Scenario: attach_file
          Given This step is passed
          When I attach file
    """
    When I run `cucumber --format AllureCucumber::Formatter --out reports/allure-report/ --format pretty`
    Then the output from "cucumber --format AllureCucumber::Formatter --out reports/allure-report/ --format pretty" should not contain "Cannot attach"
    Then the output from "cucumber --format AllureCucumber::Formatter --out reports/allure-report/ --format pretty" should contain "1 scenario (1 passed)"
    And the exit status should be 0


  @scenario4
  @scenario_pw_2_02
  @known_defect
  Scenario: Should not put 'Cannot attach...' message if file was attached into Scenario outline and  "--format AllureCucumber::Formatter --out reports/allure-report/ --format pretty" parameter was specified. BUT DOES IT
    Given a file named "features/docs/attach_file.feature" with:
    """
      Feature: title
        Scenario Outline: attach_file
          When I attach file
        Examples:
          |run_count|
          | 1       |
          | 2       |

    """
    When I run "cucumber --format AllureCucumber::Formatter --out reports/allure-report/ --format pretty"
    Then the output from "cucumber --format AllureCucumber::Formatter --out reports/allure-report/ --format pretty" should not contain "Cannot attach"
    Then the output from "cucumber --format AllureCucumber::Formatter --out reports/allure-report/ --format pretty" should contain "2 scenarios (2 passed)"
    And the exit status should be 0



  # This scenario illustrates an incorrect behaviour for scenario '@scenario4'.
  @scenario5
  Scenario: Should not be difference how much steps was run before attaching file in Scenario Outline. BUT THE DIFFERENCE IS PRESENT
    Given a file named "features/docs/attach_file.feature" with:
    """
      Feature: title
        Scenario Outline: attach_file
          Given This step is passed
          When I attach file
        Examples:
          |run_count|
          | 1       |
          | 2       |

    """
    When I run "cucumber --format AllureCucumber::Formatter --out reports/allure-report/ --format pretty"
    Then the output from "cucumber --format AllureCucumber::Formatter --out reports/allure-report/ --format pretty" should not contain "Cannot attach"
    Then the output from "cucumber --format AllureCucumber::Formatter --out reports/allure-report/ --format pretty" should contain "2 scenarios (2 passed)"
    And the exit status should be 0



  @scenario_6
  @scenario_pw_2_03
    Scenario: Should not put 'Cannot attach...' if file was attached into Background's step and  "--format AllureCucumber::Formatter --out reports/allure-report/ --format pretty" parameter was specified.
    Given a file named "features/docs/attach_file.feature" with:
    """
      Feature: title
        Background:
          When I attach file

        Scenario: attach_file
          Given This step is passed
    """
    When I run `cucumber --format AllureCucumber::Formatter --out reports/allure-report/ --format pretty`
    Then the output from "cucumber --format AllureCucumber::Formatter --out reports/allure-report/ --format pretty" should not contain "Cannot attach"
    Then the output from "cucumber --format AllureCucumber::Formatter --out reports/allure-report/ --format pretty" should contain "1 scenario (1 passed)"
    And the exit status should be 0


  @scenario_7
  @scenario_pw_2_04
  Scenario: Should not put 'Cannot attach...' if file was attached in hook Before and  "--format AllureCucumber::Formatter --out reports/allure-report/ --format pretty" parameter was specified.
    Given a file named "features/docs/attach_file.feature" with:
    """
      Feature: title
        Scenario: attach_file
          Given This step is passed
    """
    And a file named "features/lib/support/hooks.rb" with:
    """
    Before do
      File.write('temp_file', 'some_text')
      file = File.open('temp_file')
      file.close
      attach_file('some_title', file)

    end
    """
    When I run `cucumber --format AllureCucumber::Formatter --out reports/allure-report/ --format pretty`
    Then the output from "cucumber --format AllureCucumber::Formatter --out reports/allure-report/ --format pretty" should not contain "Cannot attach"
    Then the output from "cucumber --format AllureCucumber::Formatter --out reports/allure-report/ --format pretty" should contain "1 scenario (1 passed)"
    And the exit status should be 0

  @scenario_8
  @scenario_pw_2_05
  Scenario: Should not put 'Cannot attach...' if file was attached in hook After and  "--format AllureCucumber::Formatter --out reports/allure-report/ --format pretty" parameter was specified.
    Given a file named "features/docs/attach_file.feature" with:
    """
      Feature: title
        Scenario: attach_file
          Given This step is passed
    """
    And a file named "features/lib/support/hooks.rb" with:
    """
    After do
      File.write('temp_file', 'some_text')
      file = File.open('temp_file')
      file.close
      attach_file('some_title', file)

    end
    """
    When I run `cucumber --format AllureCucumber::Formatter --out reports/allure-report/ --format pretty`
    Then the output from "cucumber --format AllureCucumber::Formatter --out reports/allure-report/ --format pretty" should not contain "Cannot attach"
    Then the output from "cucumber --format AllureCucumber::Formatter --out reports/allure-report/ --format pretty" should contain "1 scenario (1 passed)"
    And the exit status should be 0


  @scenario_9
  @scenario_pw_2_07
  Scenario: Should not put 'Cannot attach...' if file was attached in hook Around when 'attach_file' is called AFTER 'block.call' and  "--format AllureCucumber::Formatter --out reports/allure-report/ --format pretty" parameter was specified.
    Given a file named "features/docs/attach_file.feature" with:
    """
      Feature: title
        Scenario: attach_file
          Given This step is passed
    """
    And a file named "features/lib/support/hooks.rb" with:
    """
    Around  do |scenario, block|
      block.call
      File.write('temp_file', 'some_text')
      file = File.open('temp_file')
      file.close
      attach_file('some_title', file)

    end
    """
    When I run `cucumber --format AllureCucumber::Formatter --out reports/allure-report/ --format pretty`
    Then the output from "cucumber --format AllureCucumber::Formatter --out reports/allure-report/ --format pretty" should not contain "Cannot attach"
    Then the output from "cucumber --format AllureCucumber::Formatter --out reports/allure-report/ --format pretty" should contain "1 scenario (1 passed)"
    And the exit status should be 0


  @scenario_10
  @scenario_pw_2_06
  Scenario: Should not put 'Cannot attach...' if file was attached in hook Around when 'attach_file' is called BEFORE 'block.call' and  "--format AllureCucumber::Formatter --out reports/allure-report/ --format pretty" parameter was specified.
    Given a file named "features/docs/attach_file.feature" with:
    """
      Feature: title
        Scenario: attach_file
          Given This step is passed
    """
    And a file named "features/lib/support/hooks.rb" with:
    """
    Around  do |scenario, block|
      File.write('temp_file', 'some_text')
      file = File.open('temp_file')
      file.close
      attach_file('some_title', file)
      block.call
    end
    """
    When I run `cucumber --format AllureCucumber::Formatter --out reports/allure-report/ --format pretty`
    Then the output from "cucumber --format AllureCucumber::Formatter --out reports/allure-report/ --format pretty" should not contain "Cannot attach"
    Then the output from "cucumber --format AllureCucumber::Formatter --out reports/allure-report/ --format pretty" should contain "1 scenario (1 passed)"
    And the exit status should be 0

  @scenario_11
  @scenario_pw_2_09
  @known_defect
  Scenario: Should not put 'Cannot attach...' message if file was attached into second step of Scenario Outline and  "--expand --format AllureCucumber::Formatter --out reports/allure-report/ --format pretty" parameter was specified.
    Given a file named "features/docs/attach_file.feature" with:
    """
      Feature: title
        Scenario Outline: attach_file
          Given This step is passed
          When I attach file
        Examples:
          |run_count|
          | 1       |
          | 2       |

    """
    When I run "cucumber --expand --format AllureCucumber::Formatter --out reports/allure-report/ --format pretty"
    Then the output from "cucumber --expand --format AllureCucumber::Formatter --out reports/allure-report/ --format pretty" should not contain "Cannot attach"
    Then the output from "cucumber --expand --format AllureCucumber::Formatter --out reports/allure-report/ --format pretty" should contain "2 scenarios (2 passed)"
    And the exit status should be 0

  @scenario_12
  @scenario_pw_2_10
  Scenario: Should not put 'Cannot attach...' if file was attached into Background's second step and  "--expand --format AllureCucumber::Formatter --out reports/allure-report/ --format pretty" parameter was specified.
    Given a file named "features/docs/attach_file.feature" with:
    """
      Feature: title
        Background:
          Given This step is passed
          And I attach file

        Scenario: attach_file
          Given This step is passed
    """
    When I run `cucumber --expand --format AllureCucumber::Formatter --out reports/allure-report/ --format pretty`
    Then the output from "cucumber --expand --format AllureCucumber::Formatter --out reports/allure-report/ --format pretty" should not contain "Cannot attach"
    Then the output from "cucumber --expand --format AllureCucumber::Formatter --out reports/allure-report/ --format pretty" should contain "1 scenario (1 passed)"
    And the exit status should be 0


  @scenario_13
  @scenario_pw_2_11
  Scenario: Should not put 'Cannot attach...' if file was attached in hook Before and  "--expand --format AllureCucumber::Formatter --out reports/allure-report/ --format pretty" parameter was specified.
    Given a file named "features/docs/attach_file.feature" with:
    """
      Feature: title
        Scenario: attach_file
          Given This step is passed
    """
    And a file named "features/lib/support/hooks.rb" with:
    """
    Before do
      File.write('temp_file', 'some_text')
      file = File.open('temp_file')
      file.close
      attach_file('some_title', file)

    end
    """
    When I run `cucumber --expand --format AllureCucumber::Formatter --out reports/allure-report/ --format pretty`
    Then the output from "cucumber --expand --format AllureCucumber::Formatter --out reports/allure-report/ --format pretty" should not contain "Cannot attach"
    Then the output from "cucumber --expand --format AllureCucumber::Formatter --out reports/allure-report/ --format pretty" should contain "1 scenario (1 passed)"
    And the exit status should be 0


  @scenario_14
  @scenario_pw_2_12
  Scenario: Should not put 'Cannot attach...' if file was attached in hook After and  "--expand --format AllureCucumber::Formatter --out reports/allure-report/ --format pretty" parameter was specified.
    Given a file named "features/docs/attach_file.feature" with:
    """
      Feature: title
        Scenario: attach_file
          Given This step is passed
    """
    And a file named "features/lib/support/hooks.rb" with:
    """
    After do
      File.write('temp_file', 'some_text')
      file = File.open('temp_file')
      file.close
      attach_file('some_title', file)

    end
    """
    When I run `cucumber --expand --format AllureCucumber::Formatter --out reports/allure-report/ --format pretty`
    Then the output from "cucumber --expand --format AllureCucumber::Formatter --out reports/allure-report/ --format pretty" should not contain "Cannot attach"
    Then the output from "cucumber --expand --format AllureCucumber::Formatter --out reports/allure-report/ --format pretty" should contain "1 scenario (1 passed)"
    And the exit status should be 0


  @scenario_15
  @scenario_pw_2_14
  Scenario: Should not put 'Cannot attach...' if file was attached in hook Around when 'attach_file' is called AFTER 'block.call' and  "--expand --format AllureCucumber::Formatter --out reports/allure-report/ --format pretty" parameter was specified.
    Given a file named "features/docs/attach_file.feature" with:
    """
      Feature: title
        Scenario: attach_file
          Given This step is passed
    """
    And a file named "features/lib/support/hooks.rb" with:
    """
    Around  do |scenario, block|
      block.call
      File.write('temp_file', 'some_text')
      file = File.open('temp_file')
      file.close
      attach_file('some_title', file)

    end
    """
    When I run `cucumber --expand --format AllureCucumber::Formatter --out reports/allure-report/ --format pretty`
    Then the output from "cucumber --expand --format AllureCucumber::Formatter --out reports/allure-report/ --format pretty" should not contain "Cannot attach"
    Then the output from "cucumber --expand --format AllureCucumber::Formatter --out reports/allure-report/ --format pretty" should contain "1 scenario (1 passed)"
    And the exit status should be 0



  @scenario_16
  @scenario_pw_2_13
  Scenario: Should not put 'Cannot attach...' if file was attached in hook Around when 'attach_file' is called BEFORE 'block.call' and  "--expand --format AllureCucumber::Formatter --out reports/allure-report/ --format pretty" parameter was specified.
    Given a file named "features/docs/attach_file.feature" with:
    """
      Feature: title
        Scenario: attach_file
          Given This step is passed
    """
    And a file named "features/lib/support/hooks.rb" with:
    """
    Around  do |scenario, block|
      File.write('temp_file', 'some_text')
      file = File.open('temp_file')
      file.close
      attach_file('some_title', file)
      block.call
    end
    """
    When I run `cucumber --expand --format AllureCucumber::Formatter --out reports/allure-report/ --format pretty`
    Then the output from "cucumber --expand --format AllureCucumber::Formatter --out reports/allure-report/ --format pretty" should not contain "Cannot attach"
    Then the output from "cucumber --expand --format AllureCucumber::Formatter --out reports/allure-report/ --format pretty" should contain "1 scenario (1 passed)"
    And the exit status should be 0


  @scenario_17
  Scenario: Should not fail if Scenario Outline was run and then Scenario where a file was attached
    Given a file named "features/docs/01_attach_file.feature" with:
    """
      Feature: title

        Scenario Outline: first outline
          Given I attach file

        Examples:
          | run_number |
          | 1 |

    """
    Given a file named "features/docs/02_attach_file.feature" with:
    """
      Feature: title
        Scenario: second scenario
          Given I attach file

    """

    When I run `cucumber --format AllureCucumber::Formatter --out reports/allure-report/ --format pretty`
    Then the output from "cucumber --format AllureCucumber::Formatter --out reports/allure-report/ --format pretty" should not contain "undefined method `[]' for nil:NilClass (NoMethodError)"
    Then the output from "cucumber --format AllureCucumber::Formatter --out reports/allure-report/ --format pretty" should contain "2 scenarios (2 passed)"
    And the exit status should be 0
