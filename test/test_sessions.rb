# frozen_string_literal: true

require "minitest/autorun"
require "kbsecret"

require_relative "helpers"

class KBSecretSessionsTest < Minitest::Test
  include Helpers

  def test_session_list
    # session_labels should always be an array
    assert_instance_of Array, KBSecret::Config.session_labels

    # ...and each element of that array should be a symbol that both satisfies
    # session? and refers to a configured session hash
    KBSecret::Config.session_labels.each do |label|
      assert_instance_of Symbol, label
      assert_instance_of Hash, KBSecret::Config.session(label)
      assert KBSecret::Config.session?(label)
    end
  end

  def test_default_session
    # the default session should always exist, and session? should take both a string
    # and a symbol
    assert KBSecret::Config.session?(:default)
    assert KBSecret::Config.session?("default")

    hsh = KBSecret::Config.session(:default)

    # the default session also has a configured hash, and that hash is the same whether
    # looked up by string or by symbol
    assert_instance_of Hash, hsh
    assert_equal hsh, KBSecret::Config.session("default")
  end

  def test_configure_and_deconfigure_session
    label, hsh = unique_label_and_session

    # configuring a unique session doesn't fail
    KBSecret::Config.configure_session(label, hsh)

    # the newly configured session satisfies session?, and does not change
    # when retrieved via Config.session
    assert KBSecret::Config.session?(label)
    assert_equal hsh, KBSecret::Config.session(label)

    # deconfiguring an session doesn't fail
    KBSecret::Config.deconfigure_session(label)
  end

  def test_deconfigure_nonexistent_session
    # deconfiguring a nonexistent session does nothing, and does not fail
    KBSecret::Config.deconfigure_session(:this_does_not_exist)
  end

  def test_new_empty_session
    label, hsh = unique_label_and_session
    KBSecret::Config.configure_session(label, hsh)
    sess = KBSecret::Session.new

    # a brand new session has an empty array of records
    assert_instance_of Array, sess.records
    assert_empty sess.records

    # a brand new session has an empty array of records of a particular type
    assert_instance_of Array, sess.records(:login)
    assert_empty sess.records(:login)

    # a brand new session has an empty array of records of a particular type,
    # even when that type doesn't correspond to a real record type
    assert_instance_of Array, sess.records(:made_up_type)
    assert_empty sess.records(:made_up_type)

    # a brand new session has an empty array of record labels
    assert_instance_of Array, sess.record_labels
    assert_empty sess.record_labels

    # a brand new session has an empty array of record paths
    assert_instance_of Array, sess.record_paths
    assert_empty sess.record_paths

    # record? always returns false in a brand new session, since there are no labels
    # to find with any label
    refute sess.record?(:foo)
  ensure
    sess&.unlink!
    KBSecret::Config.deconfigure_session(label)
  end
end