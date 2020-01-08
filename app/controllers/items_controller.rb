class ItemsController<ApplicationController

  def index
    if params[:merchant_id]
      @merchant = Merchant.find(params[:merchant_id])
      @items = @merchant.items
    else
      @items = Item.where(active?: true)
    end
  end

  def show
    @item = Item.find(params[:id])
  end

  def new
    redirect_to '/errors/404' and return unless current_user && (current_user.admin? || current_user.merchant?)
    @merchant = Merchant.find(params[:merchant_id])
  end

  def create
    @merchant = Merchant.find(params[:merchant_id])
    item = @merchant.items.create(item_params)
    if item.save
      redirect_to '/merchant/items'
      # and return if current_user && current_user.merchant?
      # redirect_to "/merchants/#{@merchant.id}/items"
    else
      flash[:error] = item.errors.full_messages.to_sentence
      render :new
    end
  end

  def edit
    redirect_to '/errors/404' and return unless current_user && (current_user.admin? || current_user.merchant?)
    @item = Item.find(params[:id])
  end

  def update
    @item = Item.find(params[:id])
    @item.update(item_params)
    if @item.save
      flash[:happy] = 'Item Updated'
      redirect_to '/merchant/items' and return if current_user && current_user.merchant?
      redirect_to "/items/#{@item.id}"
    else
      flash[:error] = @item.errors.full_messages.to_sentence
      render :edit
    end
  end

  def destroy
    item = Item.find(params[:id])
    Review.where(item_id: item.id).destroy_all
    item.destroy
    redirect_to '/merchant/items' and return if current_user && current_user.merchant?
    redirect_to "/items"
    flash[:happy] = 'Item Deleted'
  end

  private

  def item_params
    params.permit(:name,:description,:price,:inventory,:image)
  end
end
