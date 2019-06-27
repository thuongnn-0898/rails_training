User.create!(name:  "Nguyễn Thương",
  email: "thuongnn1304@gmail.com",
  password: "123123",
  password_confirmation: "123123",
  admin: true,
  activated: true,
  activated_at: Time.zone.now)
40.times do |n|
  name = Faker::Name.name
  email = "thuong#{n+1}@fpt.edu.vn"
  password = "password"
  User.create!(name: name, email: email, password: password,
    password_confirmation: password, activated: rand(2), activated_at: Time.zone.now)
end
