class ExpenditureTypesController < ApplicationController
  before_action :set_expenditure_type, only: %i[ show edit update destroy ]

  # GET /expenditure_types or /expenditure_types.json
  def index
    @expenditure_types = ExpenditureType.all
  end

  # GET /expenditure_types/1 or /expenditure_types/1.json
  def show
  end

  # GET /expenditure_types/new
  def new
    @expenditure_type = ExpenditureType.new
  end

  # GET /expenditure_types/1/edit
  def edit
  end

  # POST /expenditure_types or /expenditure_types.json
  def create
    @expenditure_type = ExpenditureType.new(expenditure_type_params)

    respond_to do |format|
      if @expenditure_type.save
        format.html { redirect_to new_expenditure_path, notice: "Expenditure type was successfully created." }
        format.json { render :show, status: :created, location: @expenditure_type }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @expenditure_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /expenditure_types/1 or /expenditure_types/1.json
  def update
    respond_to do |format|
      if @expenditure_type.update(expenditure_type_params)
        format.html { redirect_to expenditure_type_url(@expenditure_type), notice: "Expenditure type was successfully updated." }
        format.json { render :show, status: :ok, location: @expenditure_type }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @expenditure_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /expenditure_types/1 or /expenditure_types/1.json
  def destroy
    @expenditure_type.destroy

    respond_to do |format|
      format.html { redirect_to expenditure_types_url, notice: "Expenditure type was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_expenditure_type
      @expenditure_type = ExpenditureType.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def expenditure_type_params
      params.require(:expenditure_type).permit(:name)
    end
end
