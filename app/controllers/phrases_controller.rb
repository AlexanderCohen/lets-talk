class PhrasesController < ApplicationController
  before_action :set_phrase, only: %i[ show edit update destroy ]

  # GET /phrases or /phrases.json
  def index
    @phrases = current_user.phrases.order(created_at: :desc)
    @phrases = @phrases.where("text ILIKE ?", "%#{params[:search]}%") if params[:search].present?
    @phrases = @phrases.where(category: params[:category]) if params[:category].present?
    @phrases = @phrases.page(params[:page]).per(10)
  end

  # GET /phrases/1 or /phrases/1.json
  def show
  end

  # GET /phrases/new
  def new
    @phrase = current_user.phrases.build
  end

  # GET /phrases/1/edit
  def edit
  end

  # POST /phrases or /phrases.json
  def create
    @phrase = current_user.phrases.build(phrase_params)
  
    cache_key = "phrase_audio/#{Digest::SHA256.hexdigest(@phrase.text)}"
    audio_url = Rails.cache.read(cache_key)
  
    unless audio_url
      service = ElevenLabsService.new
      audio_url = service.text_to_speech(@phrase.text)
      Rails.cache.write(cache_key, audio_url, expires_in: 1.hour) if audio_url
    end
  
    respond_to do |format|
      if audio_url && @phrase.save
        @phrase.update(audio_url: audio_url)
        format.html { redirect_to phrase_url(@phrase), notice: "Phrase was successfully created." }
        format.json { render :show, status: :created, location: @phrase }
      else
        format.html { render :new, alert: "Failed to convert text to speech. Please try again." }
        format.json { render json: @phrase.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /phrases/1 or /phrases/1.json
  def update
    respond_to do |format|
      if @phrase.update(phrase_params)
        format.html { redirect_to phrase_url(@phrase), notice: "Phrase was successfully updated." }
        format.json { render :show, status: :ok, location: @phrase }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @phrase.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /phrases/1 or /phrases/1.json
  def destroy
    @phrase.destroy

    respond_to do |format|
      format.html { redirect_to phrases_url, notice: "Phrase was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_phrase
      @phrase = current_user.phrases.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def phrase_params
      params.require(:phrase).permit(:text, :category)
    end
end
