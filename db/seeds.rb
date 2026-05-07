OrderItem.destroy_all
Order.destroy_all
Product.destroy_all
Restaurant.destroy_all
User.destroy_all

puts 'Criando usuários...'

owner = User.create!(
  email: 'owner@pedmais.com',
  password: '123456',
  role: :owner
)

customer = User.create!(
  email: 'customer@pedmais.com',
  password: '123456',
  role: :customer
)

puts 'Criando restaurantes...'

restaurant1 = owner.restaurants.create!(
  name: 'Pizza do João'
)

restaurant2 = owner.restaurants.create!(
  name: 'Hamburger da Maria'
)

puts 'Criando produtos...'

Product.create!([
  {
    name: 'Pizza Calabresa',
    price: 45.0,
    restaurant: restaurant1
  },
  {
    name: 'Pizza Marguerita',
    price: 40.0,
    restaurant: restaurant1
  },
  {
    name: 'Hambúrguer Clássico',
    price: 25.0,
    restaurant: restaurant2
  }
])

puts 'Seed concluído com sucesso!'
