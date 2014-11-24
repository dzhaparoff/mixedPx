class MainpageController < ApplicationController
  def index

  response = F00px.get('photos/search',{'term' => 'sexy girl', 'sort'=>'rating' , 'rpp'=>"10" })	
	response_hash = JSON.parse(response.body)
	photos = response_hash['photos']
	require 'open-uri'
		photos.each { |photo|
			photo['ex_link'] = photo['image_url'].gsub(/\/{1}([a-zA-Z0-9_-]*).jpg/,'/2048.jpg')		
			photo['local_file'] = '/images/fh_'+photo['id'].to_s+'.jpg';
			
			photo['exist'] = File.exist?('public'+photo['local_file'])
			if !photo['exist'] 
				open('public'+photo['local_file'], 'wb') do |file|
				  file << open(photo['ex_link']).read
				end
			end
		}

	@photos = photos
	

	flickr = Flickr.new(
	  api_key:       'b6bd6a6e3a022194448999ad0d5ed203',
	  shared_secret: '0c7cf2f983a5d4c5',
	  #auth_token:    'authSecretToken',
	  verify_ssl:    false,
	  #ca_file:       '/path/to/cert.pem'
	)
	
	@fphotos = Array.new()
      
      flickr_photos = flickr.photos_search({'text'=>'sexy girl','sort'=>'interestingness-desc','per_page'=>'10'}).each do
		|p|          
        sizes = p.sizes
        single_p_hash = Hash.new()
        single_p_hash = {
            'id' => p.id,
            'original' => sizes[-1]['source'],
            'thumb'=> sizes[1]['source']
            }
          
         single_p_hash['local_file'] = '/images/fh_'+single_p_hash['id'].to_s+'.jpg';
			
          photo_exist = File.exist?('public'+single_p_hash['local_file'])
			if !photo_exist
				open('public'+single_p_hash['local_file'], 'wb') do |file|
				  file << open(single_p_hash['original']).read
				end
			end          
        
        @fphotos << single_p_hash
          
	end
  
  

  end
end