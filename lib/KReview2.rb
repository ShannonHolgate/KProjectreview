require './lib/employee'
require './lib/review'
require './lib/project'
require './lib/reviewrating'
require './lib/rating'
require './lib/pmcomment'
require './lib/emcomment'
require 'rubygems'
require 'sinatra'
require 'mongoid'
require 'haml'
require 'sinatra/base'

module KReview2

	Mongoid.load!("./lib/mongoid.yml")
	enable :sessions

	helpers do
	  def validate(username, password)
	  	puts "in validate"
	    $employee = Employee.where(:username => username, :password => password ).first
	    return $employee.nil?
	  end
	  
	  def is_logged_in?
	    session["logged_in"] == true
	  end
	  
	  def clear_session
	    session.clear
	  end
	  
	  def the_user_name
	    if is_logged_in? 
	      session["username"] 
	    else
	      "not logged in"
	    end
	  end
        
	end

	get '/' do
	  haml :login
	end

	get '/Review/New' do 
		@name = [$employee.f_name, " ",$employee.s_name].join

		@employees = Employee.all();
		@projects = Project.all();

		roles = Employee.all.distinct(:role)
		@roles = []

		roles.each do |emp|
			@roles.push(emp)
		end

		haml :new
	end

	get '/Review/Delete/:re_id' do |re_id|
		review_id = re_id.split(".")[0].to_i
		review = Review.where(:re_id => review_id)
		re_ratings = Reviewrating.where(:re_id => review_id)
		em_comments = Emcomment.where(:re_id => review_id)
		pm_comments = Pmcomment.where(:re_id => review_id)

		if !re_ratings.nil?
			re_ratings.delete
		end

		if !em_comments.nil?
			em_comments.delete
		end

		if !pm_comments.nil?
			pm_comments.delete
		end

		review.delete

		redirect '/Review/'
	end

	post '/Review/New' do

		maxEmId = Employee.max(:emp_id).to_i + 1
		maxPrId = Project.max(:pr_id)
		maxReId = Review.max(:re_id)

		if params["new-fname"].to_s.strip.length != 0
			if params["new-role"].to_s.strip.length != 0
				employee = Employee.new(:emp_id => maxEmId, :f_name => params["new-fname"].to_s, :s_name => params["new-sname"].to_s, :cm_id => 2, :role => params["new-role"].to_s,
					 :username => "#{params['new-sname']}#{maxEmId}#{params['new-fname']}", :cm_flag => false, :password => "1Password2", :pm_flag => params["new-role"].to_s == "Project Manager" ? true : false)
				employee.save
			else
				employee = Employee.new(:emp_id => maxEmId, :f_name => params["new-fname"].to_s, :s_name => params["new-sname"].to_s, :cm_id => 2, :role => params["em-role"].to_s,
					 :username => "#{params['new-sname']}#{maxEmId}#{params['new-fname']}", :cm_flag => false, :password => "1Password2", :pm_flag => params["new-role"].to_s == "Project Manager" ? true : false)
				employee.save
			end
		else
			all_emps = Employee.all()

			all_emps.each do |emp|
				if "#{emp.f_name}#{emp.s_name}".casecmp(params["em_name"].to_s.gsub(/\s+/, "")) == 0
					employee = emp
				end
			end

		end

		if params["new-proj"].to_s.strip.length != 0
			project = Project.new(:pr_id => maxPrId+=1, :name => params["new-proj"].to_s)
			project.save
		else
			project = Project.where(:name => params["proj"]).first
			project.save
		end

		review = Review.new(:re_id => maxReId+=1, :pr_id => project.pr_id, :emp_id => employee.emp_id, :pm_id => $employee.emp_id, :rev_start => Date.parse(params["period_from"].to_s), :rev_end => Date.parse(params["period_to"].to_s))
		review.save

		redirect '/Review/'

	end

	get '/Review/:emp_id/:re_id' do |emp_id, re_id|
		review_id = re_id.split(".")[0].to_i
		employee_id = emp_id.split(".")[0].to_i

		@name = [$employee.f_name, " ",$employee.s_name].join

		@employee = Employee.where(:emp_id => employee_id).first
		@review = Review.where(:re_id => review_id).first
		@career_manager = Employee.where(:emp_id => @employee.cm_id).first
		@project = Project.where(:pr_id => @review.pr_id).first
		@sections = Rating.all() #Rating is Factors

		roles = Employee.all.distinct(:role)
		@roles = []

		roles.each do |emp|
			@roles.push(emp)
		end

  	maxEmCom = Emcomment.max(:emc_id)
  	maxPmCom = Pmcomment.max(:pmc_id)
  	maxRevRating = Reviewrating.max(:rev_id)

		if Emcomment.where(:re_id => @review.re_id).exists?
			@em_comments = Emcomment.where(:re_id => @review.re_id)
		else
			(1..9).each do |com|
				em_comments_new = Emcomment.new(:emc_id => maxEmCom+=1, :re_id => review_id, :ra_id => com, :desc => "")
				em_comments_new.save
			end
			@em_comments = Emcomment.where(:re_id => @review.re_id)
		end

		if Pmcomment.where(:re_id => @review.re_id).exists?
			@pm_comments = Pmcomment.where(:re_id => @review.re_id)
		else
			(1..9).each do |com|
				pm_comments_new = Pmcomment.new(:pmc_id => maxPmCom+=1, :re_id => review_id, :ra_id => com, :desc => "")
				pm_comments_new.save
			end
			@pm_comments = Pmcomment.where(:re_id => @review.re_id)
		end

		if Reviewrating.where(:re_id => @review.re_id).exists?
			@review_rating = Reviewrating.where(:re_id => review_id)
		else
			(1..9).each do |com|
				review_ratings_new = Reviewrating.new(:rev_id => maxRevRating+=1, :re_id => review_id, :ra_id => com, :rating => 0)
				review_ratings_new.save
			end
			@review_rating = Reviewrating.where(:re_id => review_id)
		end

	  haml :Edit
	end

	post '/Review/:emp_id/:re_id' do |emp_id, re_id|
		review_id = re_id.split(".")[0].to_i
		employee_id = emp_id.split(".")[0].to_i

		(1..9).each do |com|
			pm_comment = Pmcomment.where(:re_id => review_id, :ra_id => com).first
			pm_description = params["desc." + com.to_s + ".0"].to_s
			if pm_description.to_s.strip.length == 0
  			# It's nil, empty, or just whitespace
  			pm_description = params["desc." + com.to_s].to_s
			end
			pm_comment[:desc] = pm_description
			pm_comment.save

			em_comment = Emcomment.where(:re_id => review_id, :ra_id => com).first
			em_description = params["em_desc." + com.to_s + ".0"].to_s
			if em_description.to_s.strip.length == 0
  			# It's nil, empty, or just whitespace
  			em_description = params["em_desc." + com.to_s].to_s
			end
			em_comment[:desc] = em_description
			em_comment.save

			review_rating = Reviewrating.where(:re_id => review_id, :ra_id => com).first
			ratings = params["rating." + com.to_s + ".0"]
			if ratings.nil?
				ratings = params["rating." + com.to_s]
			end
			review_rating[:rating] = ratings.to_i
			review_rating.save
		end

		employee = Employee.where(:emp_id => employee_id).first

		if params["new-role"].to_s.strip.length == 0
			employee[:role] = params["em_role"]
			puts params["em_role"]
			employee.save
		else
			employee[:role] = params["new-role"]
			puts params["em_role"]
			employee.save
		end

	  redirect '/Review/'+ emp_id + '/' + re_id
	end

	post '/login' do
    @name = "#{@params[:name]}"
    @pass = "#{@params[:pass]}"

    puts @name + " " @pass

    if(!validate(@name, @pass))
			session["logged_in"] = true
	    session["username"] = params["username"]
	    redirect '/Review/'
	  else
	    redirect '/'
	  end
  end

	get '/Review/' do 
		@name = [$employee.f_name, " ",$employee.s_name].join
	  @reviews = Review.where(:pm_id => $employee.emp_id)

    pr_ids = []
    emp_ids = []
    Review.where(:pm_id => $employee.emp_id).each do |app|
  			pr_ids.push(app.pr_id)
  			emp_ids.push(app.emp_id)
		end

    @projects = Project.in(pr_id: pr_ids)
    @employees = Employee.in(emp_id: emp_ids)
    haml :reviews
	end
end
