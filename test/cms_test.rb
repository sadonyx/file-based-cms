ENV["Rack_env"] = "test"

require "minitest/autorun"
require "rack/test"
require "redcarpet"

require_relative "../cms"

class CMSTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_index
    get "/"

    assert_equal 200, last_response.status
    assert_equal "text/html;charset=utf-8", last_response["Content-Type"]
    assert_includes last_response.body, "about.txt"
    assert_includes last_response.body, "sample.md"
    assert_includes last_response.body, "changes.txt"
    assert_includes last_response.body, "history.txt"

  end

  def test_viewing_test_document
    get "/history.txt"

    assert_equal 200, last_response.status
    assert_equal "text/plain", last_response["Content-Type"]
    assert_includes last_response.body, "1993 - Yukihiro Matsumoto dreams up Ruby."
  end

  def test_document_not_found
    get "/gabagool.txt"

    assert_equal 302, last_response.status

    get last_response["Location"]

    assert_equal 200, last_response.status
    assert_includes last_response.body, "gabagool.txt does not exist."

    get "/"
    refute_includes last_response.body, "gabagool.txt does not exist."
  end

  def test_markdown_render
    get "/sample.md"

    assert_equal 200, last_response.status
    assert_equal "text/html;charset=utf-8", last_response["Content-Type"]
    assert_includes last_response.body, "<h2>This is a sample</h2>"
  end

  def test_editing_document
    get "/changes.txt/edit"

    assert_equal 200, last_response.status
    assert_includes last_response.body, "<textarea"
    assert_includes last_response.body, %q(<button type="submit")
  end

  def test_updating_document
    post "/changes.txt", content: "new content"

    assert_equal 302, last_response.status

    get last_response["Location"]

    assert_includes last_response.body, "changes.txt has been updated"

    get "/changes.txt"
    assert_equal 200, last_response.status
    assert_includes last_response.body, "new content"
  end
end