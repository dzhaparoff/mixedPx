module ApplicationHelper
	def cp(path)
  		" current active" if current_page?(path)
	end

	def cat_list
		cat_list = Category.where("photos_count >= 20").order(sort: :asc).all
	end

	def title(page_title)
 		content_for :title, page_title.to_s
	end

	def fresh_photos_count
		interval = APP_CONFIG['fresh_interval']
		day = Date.today
		fresh_photos_count = Photo.where(:created_at => ((day-interval).beginning_of_day .. day.end_of_day)).size
	end

	def format_city_country user
		format = String.new
		format << " - " << user.city.titleize if ( user.city.size > 0 )
		format << ", " if (user.city.size > 0 && user.country.size > 0)
		format << user.country.titleize if user.country.size > 0
		return format
	end
end