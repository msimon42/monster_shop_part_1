class OrdersController < ApplicationController

  def new
  end

  def show
    if current_user && current_user.default?
      @order = Order.find(params[:id])
    else
      render 'errors/404'
    end     
  end

  def create
    order = Order.create(order_params)
    current_user.orders << order
    if order.save
      cart.items.each do |item,quantity|
        order.item_orders.create({
          item: item,
          quantity: quantity,
          price: item.price
          })
      end
      session.delete(:cart)
      redirect_to "/orders/#{order.id}"
    else
      flash[:notice] = "Please complete address form to create an order."
      render :new
    end
  end

  def index
    if current_user && current_user.default?
      @orders = current_user.orders
    else
      render 'errors/404'
    end
  end

  private

  def order_params
    params.permit(:name, :address, :city, :state, :zip)
  end

end
