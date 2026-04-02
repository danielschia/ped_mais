class ProcessOrderJob
  include Sidekiq::Job

  def perform(order_id)
    order = Order.find(order_id)

    order.update(status: 'processing')
    puts "Processing order #{order.id} for user #{order.user_id}"
    sleep(10)
    order.update(status: 'completed')
  end
end
