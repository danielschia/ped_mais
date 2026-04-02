class OrderProcessorJob < ApplicationJob
  queue_as :default

  def perform(order_id)
    order = Order.find(order_id)

    puts "Processing order #{order.id}"

    sleep 5

    order.update(status: "completed")

    puts "Order completed!"
  end
end
