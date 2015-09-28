class OrderController < ApplicationController

	skip_before_action :verify_authenticity_token

	protect_from_forgery except: [:hook]

	#paypal webhook
  	def hook
    	params.permit! # Permit all Paypal input params
    	status = params[:payment_status]
    	if status == "Completed"
      	@order = Order.find params[:invoice]
      	@order.update_attributes notification_params: params, status: status, transaction_id: params[:txn_id], purchased_at: Time.now
    	end
    	render nothing: true
  	end

	def index
		@order = Order.new
	end

	def create
		params.permit!
		@order = Order.new

		#build the order object from POST params
		@order.contents = ""
		@order.total = 0
		@order.name = params[:name]
		@order.email = params[:email]
		@order.number = params[:number]
		@order.location = params[:location]
		#burrito params
		if params[:chicken].to_f > 0
			@order.contents += params[:chicken]
			@order.contents += "chicken,"
			@order.total += 12* params[:chicken].to_f
		end
		if params[:steak].to_f > 0
			@order.contents += params[:steak]
			@order.contents += "steak"
			@order.contents += ","
			@order.total += 12* params[:steak].to_f
		end
		if params[:barb].to_f > 0
			@order.contents += params[:barb]
			@order.contents += "barb"
			@order.contents += ","
			@order.total += 12* params[:barb].to_f
		end
		if params[:veg].to_f > 0
			@order.contents += params[:veg]
			@order.contents += "veg"
			@order.contents += ","
			@order.total += 12* params[:veg].to_f
		end
		if params[:carn].to_f > 0
			@order.contents += params[:carn]
			@order.contents += "carnitas"
			@order.contents += ","
			@order.total += 12* params[:carn].to_f
		end

		#Combo Param
		if params[:ChipMole].to_f > 0
			@order.contents += params[:ChipMole]
			@order.contents += "chip/mole"
			@order.contents += ","
			@order.total += 5* params[:ChipMole].to_f
		end

		if params[:drink].to_f > 0
			@order.contents += params[:drink]
			@order.contents += "drink"
			@order.contents += ","
			@order.total += 2* params[:drink].to_f
		end



		if @order.save
			redirect_to @order.paypal_url(order_path(@order))
		end
	end

	def new
	end

	def complete
		params.permit!
		@all = params
	end

end