require "sinatra"
require "sinatra/reloader" if development?
require "sinatra/content_for"

root = File.expand_path("..", __FILE__)

get "/" do
  @files = Dir.glob(root + "/data/*").map do |path|
    File.basename(path)
  end
 erb :index
end

get "/:file" do
  file_path =root + "/data/" + params[:file]

  headers["Content-Type"] = "text/plain"
  File.read(file_path)
end