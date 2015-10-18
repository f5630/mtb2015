require "sinatra"
require "sqlite3"
require "json"

set :environment, :production
set :port, 80

get "/searchOrder" do 
	content_type :json
	status 200


	if params.has_key?("limit") then
	 	limit = params["limit"].to_i 
		params.delete("limit")
	else
		limit = 100
	end
	
	array = params.to_a

	method = Array.new
	method_param = Array.new

	size = array.length - 1  

	0.upto(size){|index|
		method.push(array[index][0])
		method_param.push(array[index][1])
	}

	result = true
	error = false
	#result = false

	sql = Array.new()

	method.each_with_index{|val,index|
		case val
		when "findByOrderDateTimeGTE" then
			sql.push("orderDateTime >= '#{method_param[index]}'")
		when "findByOrderDateTimeLTE" then
			sql.push("orderDateTime <= '#{method_param[index]}'")
		when "findByOrderUserId" then
			sql.push("orderUserId = '#{method_param[index]}'")
		when "findByOrderItemId" then
			sql.push("orderItemId = '#{method_param[index]}'")
		when "findByOrderQuantityGTE" then
			sql.push("orderQuantity >= '#{method_param[index]}'")
		when "findByOrderQuantityLTE" then
			sql.push("orderQuantity <= '#{method_param[index]}'")
		when "findByOrderState" then
			sql.push("orderState = '#{method_param[index]}'")
		when "findByOrderTagsIncludeAll" then
			sql.push("orderTags = '#{method_param[index]}'")
		when "findByOrderTagsIncludeAny" then
			sql.push("orderTags like '#{method_param[index]}'")
		else
			error = true
		end

	}

	final_sql = "select * from od2 where "
	sql.each{|val|
		final_sql = final_sql + val.to_s + " and "
	}

	final_sql = final_sql.slice(0..final_sql.length-6)

	if sql.empty? || error == true then	
		#引数がおかしい
		result = false
		datahash = "null"
		status 404
	end

	datahash = Array.new
	#result = false
	if(result == true) then

		#検索
		db = SQLite3::Database.new("ca.sqlite3")
		db.results_as_hash = true
		data = db.execute(final_sql)

		#if data.length == 0 then 
		if data.empty? then
			#データがない
			result = false
			datahash = "null"
			status 404
		else
			data.each_with_index{|val,index|

				break if index > (limit-1)
				
				0.upto(6){|i|
					val.delete(i)
				}
				val["orderTags"] = val["orderTags"].split(",")
				datahash.push(val)
				val["orderDateTime"] = val["orderDateTime"].to_i	
				val["orderQuantity"] = val["orderQuantity"].to_i
			}
			result = true

		end
	end


	#envelope = {"result" => result,"data" => datahash,"method" => method_param,"param" => final_sql}
	#envelope = {"result" => result,"data" => datahash,"sql" => final_sql}
	
	envelope = {"result" => result,"data" => datahash}
	envelope.to_json
end

get "/test" do
	content_type :json
	a = ["aaa","bbb"]
	a.to_json

end
