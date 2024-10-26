class PhrasesController < ApplicationController
    before_action :set_phrase, only: %i[ show edit update destroy archive unarchive ]
    before_action :set_categories, only: [:new, :create, :edit, :update, :index]
    include Rails.application.routes.url_helpers

    def audio_full_url
      rails_blob_url(audio_url, only_path: false)
    end
    # GET /phrases or /phrases.json
    def index
        @phrases = current_user.phrases.active.order(created_at: :desc)
        @phrases = @phrases.where("text ILIKE ?", "%#{params[:search]}%") if params[:search].present?
        @phrases = @phrases.where(category: params[:category]) if params[:category].present?
        @phrases = @phrases.page(params[:page]).per(10)
        @phrase = current_user.phrases.build
        @categories = current_user.phrase_categories
    end
  
    def new
      @phrase = current_user.phrases.build
    end

    # POST /phrases or /phrases.json
    def create
      @phrase = current_user.phrases.build(phrase_params.except(:new_category))
      @phrase.generate_audio(current_users_voice_service)

      @new_category = !@categories.include?(@phrase.category)
      @categories << @phrase.category if @new_category

      respond_to do |format|
        if @phrase.save
          format.turbo_stream
          format.html { redirect_to phrases_url, notice: "Phrase was successfully created." }
        else
          format.turbo_stream { render turbo_stream: turbo_stream.replace('new_phrase_form', partial: 'form', locals: { phrase: @phrase }) }
          format.html { render :new, status: :unprocessable_entity }
        end
      end
    end
  
    # PATCH/PUT /phrases/1 or /phrases/1.json
    def update
      respond_to do |format|
        if @phrase.update(phrase_params)
          format.turbo_stream
          format.html { redirect_to phrase_url(@phrase), notice: "Phrase was successfully updated." }
        else
          format.turbo_stream { render turbo_stream: turbo_stream.replace(@phrase, partial: 'form', locals: { phrase: @phrase }) }
          format.html { render :edit, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /phrases/1 or /phrases/1.json
    def destroy
      @phrase.destroy
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to phrases_url, notice: "Phrase was successfully destroyed." }
      end
    end
  
    def archive
      @phrase.update(archived: true)
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.remove(@phrase) }
        format.html { redirect_to phrases_url, notice: 'Phrase was successfully archived.' }
      end
    end
  
    def unarchive
      @phrase.update(archived: false)
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.remove(@phrase) }
        format.html { redirect_to archived_phrases_url, notice: 'Phrase was successfully unarchived.' }
      end
    end
  
    def archived
      @archived_phrases = current_user.phrases.where(archived: true).order(created_at: :desc)
    end
  
    def fetch_suggestions
      phrase = params[:phrase]
      
      # Dummy suggestions for now
      suggestions = OpenAiService.new.suggest_phrase_completions(phrase)
      
      suggestions = Array(suggestions)
      suggestions = suggestions.first if suggestions.size == 1 && suggestions.first.is_a?(Array)
      suggestions = suggestions.compact.uniq

      render turbo_stream: turbo_stream.update(
        "suggestions",
        partial: "phrases/suggestions",
        locals: { suggestions: suggestions }
      )
    end
  
    private
  
      def set_phrase
        @phrase = current_user.phrases.find(params[:id])
      end

      def set_categories
        @categories = current_user.phrase_categories
      end
  
      def phrase_params
        params.require(:phrase).permit(:text, :category, :new_category)
      end

    def audio
      @phrase = Phrase.find(params[:id])
      
      respond_to do |format|
        format.json do
          if @phrase.audio.attached?
            # Generate a short-lived URL for the audio
            blob = @phrase.audio.blob
            audio_data = {
              url: rails_blob_path(blob, disposition: "attachment"),
              filename: blob.filename.to_s,
              content_type: blob.content_type,
              byte_size: blob.byte_size
            }
            
            render json: audio_data
          else
            render json: { error: 'No audio attached' }, status: :not_found
          end
        end
        
        # Direct binary response for sharing
        format.binary do
          if @phrase.audio.attached?
            send_data @phrase.audio.download,
                     filename: @phrase.audio.filename.to_s,
                     content_type: @phrase.audio.content_type,
                     disposition: 'attachment'
          else
            head :not_found
          end
        end
      end
    end
  end
