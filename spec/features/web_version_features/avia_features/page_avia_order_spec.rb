require 'rails_helper'
require 'support/auth_helper'
require 'support/root_path_helper'
require 'support/avia_booking_helper'
require 'support/avia_search_helper'
require 'support/avia_test_data_helper'

describe 'Page avia order for round search' do
  include AviaSearch
  include AviaBooking
  include AuthHelper
  # include TestData

  search = DataRoundSearch.new
  type_avia_search = search.type_avia_search
  params_avia_location = search.params_avia_location
  params_flight_dates = search.params_flight_dates
  params_passengers = search.params_passengers

  before do
    visit($root_path_avia)
    params_flight_dates[:date_departure] = increase_date_flight(params_flight_dates[:date_departure])
    params_flight_dates[:date_arrival] = increase_date_flight(params_flight_dates[:date_arrival])
  end

  it 'check regular booking without input data', retry: 3 do
    if $url_page_booking_round_regular.length > 0
      visit($url_page_booking_round_regular)
    else
      $url_page_booking_round_regular = try_open_booking_page_for_regular($url_recommendation_round, type_avia_search, params_avia_location, params_flight_dates, params_passengers)
    end
    find('.order_form__button_role-submit').click
    expect(page).to have_selector('.field_with_errors')
    expect(page.current_url == $url_page_booking_round_regular).to be(true)
  end

  it 'check availability to autorization and choose first passenger passenger usual user in regular booking', retry: 3 do
    if $url_page_booking_round_regular.length > 0
      visit($url_page_booking_round_regular)
    else
      $url_page_booking_round_regular = try_open_booking_page_for_regular($url_recommendation_round, type_avia_search, params_avia_location, params_flight_dates, params_passengers)
    end
    auth_from_booking_page('test@example.com', 'qwerty123')
    # click and check first passenger from dropdown list
    expect(page).to have_selector('.avia_order_form')
    first('[data-class="Avia.PassengersDropdown"]').click
    first('.order_form_passengers_dropdown__menu_item_link').click
    expect(first('.avia_order_journey_item_element_documents_firstname input').value.length > 0).to be(true)
  end

  it 'check availability to autorization with agent email in regular booking', retry: 3 do
    if $url_page_booking_round_regular.length > 0
      visit($url_page_booking_round_regular)
    else
      $url_page_booking_round_regular = try_open_booking_page_for_regular($url_recommendation_round, type_avia_search, params_avia_location, params_flight_dates, params_passengers)
    end
    auth_from_booking_page('test@test.ua', 'test123')
    # check after autorization will bу new search
    expect(page).to have_selector('.trip_search__progressbar_indicator_done')
    check_lowcosts_and_regular_recommendations
  end

  it 'check availability to autorization and choose first passenger passenger usual user in lowcost', retry: 3 do
    if $url_page_booking_round_lowcost.length > 0
      visit($url_page_booking_round_lowcost)
    else
      $url_page_booking_round_lowcost = try_open_booking_page_for_lowcost($url_recommendation_round, type_avia_search, params_avia_location, params_flight_dates, params_passengers)
    end
    auth_from_booking_page('test@example.com', 'qwerty123')
    # click and check first passenger from dropdown list
    expect(page).to have_selector('.avia_kiwi_order_form')
    first('[data-class="Avia.PassengersDropdown"]').click
    first('.order_form_passengers_dropdown__menu_item').click
    expect(first('.avia_kiwi_order_journey_item_element_documents_firstname input').value.length > 0).to be(true)
  end

  it'check choice baggage in lowcost order page', retry: 3 do
    if $url_page_booking_round_lowcost.length > 0
      visit($url_page_booking_round_lowcost)
    else
      $url_page_booking_round_lowcost = try_open_booking_page_for_lowcost($url_recommendation_round, type_avia_search, params_avia_location, params_flight_dates, params_passengers)
    end
    # click button choose baggage
    expect(page).to have_selector('.avia_kiwi_order_form')

    first('.order_form__add_baggage_button').click
    # choose 1 baggage
    first('[for="avia_kiwi_order_journey_item_attributes_element_attributes_documents_attributes_0_additional_baggage_quantity_1"]').click
    expect(page).to have_selector('.notify_message_layout-modal_dialog')
    find('[data-role="avia.kiwi.orders.error_message.continue"]').click
    expect(page).not_to have_selector('.notify_message_layout-modal_dialog')
  end
end