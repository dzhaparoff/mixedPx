class Admin::Api::ApiController < Admin::AdminController
  
# skip_before_filter :verify_authenticity_token
  
  def fh_check
    @params = params['formData']   
    @responce = fh_photos_search @params
    render json: @responce
  end 

  def get_photos
    photos = Array.new
    ph = Photo.select('photo_id').all
    ph.each do |p|
      photos << p.photo_id
    end
    render json: photos
  end

  def get_photo
    response = F00px.get('photos/' + params[:id], params)
    response_hash = JSON.parse(response.body)
    doc_href = 'https://500px.com' + response_hash['photo']['url']
    doc = Nokogiri::HTML(open(doc_href))
    img_url = doc.css('meta[property="og:image"]').first
    response_hash['photo']['image_url'] = img_url['content']

    @response_hash = response_hash
    render json: @response_hash
  end

  def sync_old_photos
    render_out = ''
    Photo
      .where('id <= ? AND id >= ?', params[:end], params[:start])
      .find_each(batch_size: 10) do |photo|
      response_promise = F00px.get('photos/' + photo.photo_id.to_s)
      response = JSON.parse(response_promise.body)
      photo_f = response['photo']
      photo.iso = photo_f['iso']
      photo.focal_length = photo_f['focal_length']
      photo.shutter_speed = photo_f['shutter_speed']
      photo.aperture = photo_f['aperture']
      photo.latitude = photo_f['latitude']
      photo.longitude = photo_f['longitude']
      photo.save
      render_out << photo.id.to_s + " - Обновлен \n\r"
    end
    render text: render_out
  end

  def resave_all_photos
    Photo.find_each(batch_size: 50) do |photo|
      photo.save
    end
    render text: 'all_done'
  end

  def resave_best_photos
    day = Photo.first_photo.created_at.to_date
    first_photo_day = Date.today
    log = ''
    begin
      begin
        log << ' ' << day.to_s
        best_photo_of_day = Photo.best_photos_of_the_day(day).take
        best_photo_of_day.save unless best_photo_of_day.nil?
        day += 1
      end while best_photo_of_day.nil?
    end while day <= first_photo_day
    render text: 'all_done ' << log
  end

  private

  def fh_photos_search(params)
    response = F00px.get('photos/search',
                         'term' => params['term'],
                         'sort' => params['sort'],
                         'rpp' => params['rpp'],
                         'only' => params['category'],
                         'image_size' => '3')
    response_hash = JSON.parse(response.body)

    photos = response_hash['photos']

    photos.each do |photo|
      photo['local_image_url'] = '/images/fh_' + photo['id'].to_s + '.' + photo['image_format']
    end

    response_hash['photos'] = photos
    response_hash
   end
end
