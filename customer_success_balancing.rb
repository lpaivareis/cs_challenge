# frozen_string_literal: true

require 'minitest/autorun'
require 'timeout'
require 'byebug'

class CustomerSuccessBalancing
  attr_reader :customer_success, :customers, :away_customer_success

  def initialize(customer_success, customers, away_customer_success)
    @customer_success = customer_success
    @customers = customers
    @away_customer_success = away_customer_success
  end

  def execute
    return 0 if max_away_permited

    remove_away_cs

    sort_cs

    validate_customer_success_and_customer

    return 0 if remove_cs_without_customer

    customer_success_interaction

    return 0 if customer_success.size > 1 && check_tie

    result
  end

  private

  def remove_away_cs
    return if away_customer_success.empty?

    away_customer_success.each do |away_cs|
      customer_success.delete_if { |cs| cs[:id] == away_cs }
    end
  end

  def sort_cs
    customer_success.sort_by! { |cs| cs[:score] }
  end

  def validate_cs
    customer_success.count > 1000 || customer_success.count < 1
  end

  def validate_customer
    customers.count > 10_000 || customers.count < 1
  end

  def validate_customer_success_and_customer
    return 0 if validate_cs || validate_customer
  end

  def remove_cs_without_customer
    min_score = customers.min_by { |customer| customer[:score] }[:score]
    customer_success.reject! { |cs| cs[:score] < min_score }

    customer_success.empty?
  end

  def max_away_permited
    return false if away_customer_success.empty?

    away_customer_success.count > (customer_success.count / 2)
  end

  def validate_id_cs(cs_id)
    cs_id < 1 || cs_id > 100_000
  end

  def validate_cs_score(cs_score)
    cs_score < 1 || cs_score > 10_000
  end

  def customer_success_interaction
    customer_success.each do |cs|
      next if validate_id_cs(cs[:id]) || validate_cs_score(cs[:score])

      customers_interaction(cs)
    end
  end

  def validate_size_customer(customer_score)
    customer_score < 1 || customer_score > 100_000
  end

  def validate_id_customer(customer_id)
    customer_id < 1 || customer_id > 1_000_000
  end

  def customers_interaction(c_success)
    customers.each do |customer|
      next if validate_id_customer(customer[:id]) || validate_size_customer(customer[:score])

      next unless (c_success[:score] >= customer[:score]) && !customer[:serviced]

      c_success[:quantity] ||= 0
      c_success[:quantity] += 1
      customer[:serviced] = true
    end
  end

  def check_tie
    customer_success.map { |cs| cs[:quantity] }.uniq.count == 1
  end

  def result
    customer_success.delete_if { |cs| cs[:quantity].nil? }.sort_by! { |cs| cs[:quantity] }.last[:id]
  end
end

class CustomerSuccessBalancingTests < Minitest::Test
  def test_scenario_one
    balancer = CustomerSuccessBalancing.new(
      build_scores([60, 20, 95, 75]),
      build_scores([90, 20, 70, 40, 60, 10]),
      [2, 4]
    )
    assert_equal 1, balancer.execute
  end

  def test_scenario_two
    balancer = CustomerSuccessBalancing.new(
      build_scores([11, 21, 31, 3, 4, 5]),
      build_scores([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]),
      []
    )
    assert_equal 0, balancer.execute
  end

  def test_scenario_three
    balancer = CustomerSuccessBalancing.new(
      build_scores(Array(1..999)),
      build_scores(Array.new(10_000, 998)),
      [999]
    )
    result = Timeout.timeout(1.0) { balancer.execute }
    assert_equal 998, result
  end

  def test_scenario_four
    balancer = CustomerSuccessBalancing.new(
      build_scores([1, 2, 3, 4, 5, 6]),
      build_scores([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]),
      []
    )
    assert_equal 0, balancer.execute
  end

  def test_scenario_five
    balancer = CustomerSuccessBalancing.new(
      build_scores([100, 2, 3, 6, 4, 5]),
      build_scores([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]),
      []
    )
    assert_equal 1, balancer.execute
  end

  def test_scenario_six
    balancer = CustomerSuccessBalancing.new(
      build_scores([100, 99, 88, 3, 4, 5]),
      build_scores([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]),
      [1, 3, 2]
    )
    assert_equal 0, balancer.execute
  end

  def test_scenario_seven
    balancer = CustomerSuccessBalancing.new(
      build_scores([100, 99, 88, 3, 4, 5]),
      build_scores([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]),
      [4, 5, 6]
    )
    assert_equal 3, balancer.execute
  end

  def test_scenario_eight
    balancer = CustomerSuccessBalancing.new(
      build_scores([60, 40, 95, 75]),
      build_scores([90, 70, 20, 40, 60, 10]),
      [2, 4]
    )
    assert_equal 1, balancer.execute
  end

  private

  def build_scores(scores)
    scores.map.with_index do |score, index|
      { id: index + 1, score: score }
    end
  end
end
