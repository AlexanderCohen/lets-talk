class PhrasesController < ApplicationController
    before_action :set_phrase, only: %i[ show edit update destroy ]
  
    # GET /phrases or /phrases.json
    def index
        @phrases = current_user.phrases.order(created_at: :desc)
        @phrases = @phrases.where("text ILIKE ?", "%#{params[:search]}%") if params[:search].present?
        @phrases = @phrases.where(category: params[:category]) if params[:category].present?
        @phrases = @phrases.page(params[:page]).per(10)
        @phrase = current_user.phrases.build
    end
  
    def new
      @phrase = current_user.phrases.build
    end

    # POST /phrases or /phrases.json
    def create
      @phrase = current_user.phrases.build(phrase_params)
      service = ElevenLabsService.new
      audio_content = service.text_to_speech(@phrase.text)

      if audio_content
        @phrase.audio.attach(io: StringIO.new(audio_content), filename: "#{SecureRandom.uuid}.mp3", content_type: "audio/mp3")
      end

      respond_to do |format|
        if @phrase.save
          format.turbo_stream
          format.html { redirect_to phrases_url, notice: "Phrase was successfully created." }
        else
          format.turbo_stream { render turbo_stream: turbo_stream.replace('new_phrase', partial: 'form', locals: { phrase: @phrase }) }
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
  
    private
  
      def set_phrase
        @phrase = current_user.phrases.find(params[:id])
      end
  
      def phrase_params
        params.require(:phrase).permit(:text, :category)
      end
  end