class ProcessOrderJob
  include Sidekiq::Job

  def perform(order_id)
    order = Order.find(order_id)

    Rails.logger.info(
      "Novo pedido ##{order.id} criado por #{order.user.email}"
    )

    # Simulação de processamento assíncrono
    sleep(5)

    Rails.logger.info(
      "Pedido ##{order.id} enviado para o restaurante."
    )
  end
end
