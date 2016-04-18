# облегченный шаблон для sinatra + bootstrap

#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'pony'

# главная страница
get '/' do
	erb "<h1> Hello! We are GREAT!!! </h1>"
end

# о нас
get '/about' do
	erb :about
end

# запись
get '/visit' do
	erb :visit
end

# отправка сообщений
get '/contacts' do
	erb :contacts
end

# запрос админского пароля
get '/admin' do
	erb :admin
end

# обработка записи
post '/visit' do

	# переменные содержащие значения полей ввода
	@username=params[:username]
	@phone=params[:phone]
	@data=params[:data]
	@candy=params[:candy]
	@colorpicker=params[:colorpicker]

	# формируем сообщение о возможных ошибках
	@error=get_error_message({:username => "Enter username.\n", :phone => "Enter phone.\n", :data => "Enter data.\n"})

	# если сформированно сообщение об ошибке, форма выводится заново. При этом введенные значения полей остаются
	# если сообщение об ошибке пустое, данные из формы записываются в файл
	if @error!=""
		erb :visit
	else
		f=File.open("./public/users.txt", "a")
		f.write "#{@username} (tel. #{@phone}) visit on #{@data} and meet with #{@candy} or select #{@colorpicker} color\n" 
		f.close
		erb "<h2>Congratulations! You make an appointment.</h2>"
	end
end

# обработка отправленных сообщений - сообщения записываются в файл
post '/contacts' do

	# переменные содержащие значения полей ввода
	@email=params[:email]
	@message=params[:message]
	
	# формируем сообщение о возможных ошибках
	@error=get_error_message({:email => "Enter email.\n", :message => "Enter message.\n"})

	# если сформированно сообщение об ошибке, форма выводится заново. При этом введенные значения полей остаются
	# если сообщение об ошибке пустое, отсылаестя контрольное сообщение и данные из формы записываются в файл
	if @error!=""
		erb :contacts
	else

		send_mail({:mymail => @email, :mymsubj => "CandyShop", :mymessage => "You send a message:\n\n#{@message}\n\nWe got it and will soon get back to you." })
		f=File.open("./public/contacts.txt", "a")
		f.write "#{@email} send:\n" 
		f.write "#{@message}\n\n"
		f.close
		erb "<h2>Thank You! Your message will be reviewed in the near future.</h2>"
	end
end

# обработка админского логина и пароля - если верен - запуск в админскую область
post '/admin' do
	if params[:login]=="admin" && params[:password]=="secret"
		erb :files
	else
		erb "<h4>Sorry. Login or Password is wrong.</h4>"
	end
end

# возвращает сообщение о возможных ошибках. принмимает хеш с парой
# имя_параметра=>выводимое сообщение. если параметр пустой, формируется сообщение
def get_error_message(hh)
	err=""
	hh.each_key {|param| err+=hh[param] if params[param].strip==""}
	return err
end

# отсылка заданного сообщения с заданной темой на заданный адрес
def send_mail(hh)
	Pony.mail({
			:to => hh[:mymail],
			:via => :smtp,
			:subject => hh[:mymsubj],
			:body => hh[:mymessage],
			:via_options => {
						:address              => 'smtp.gmail.com',
						:port                 => '587',
						:enable_starttls_auto => true,
						:user_name            => 'suburbakskin@gmail.com',
						:password             => 'assassin6871',
						:authentication       => :plain,
						:domain               => "localhost.localdomain"
							}
		})
end