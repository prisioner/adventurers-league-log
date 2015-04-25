class DmLogEntriesController < AuthenticationController
  skip_before_action :authenticate_user!, only: [:index, :show]

  add_crumb('Home', '/')
  before_filter :load_user
  before_filter :load_characters, only: [:new, :create, :edit, :update]
  before_filter :load_log_entry,  only: [:show, :edit, :update, :destroy]
  before_filter :load_adventure_form_inputs, only: [:new, :create, :edit, :update]
  before_filter :load_overrides, only: [:edit, :update]

  before_filter() { add_crumb('DM Logs', user_dm_log_entries_path(@user)) }
  before_filter(only: [:new])  { add_crumb "New Log Entry" }
  before_filter(only: [:edit]) { add_crumb "Edit Log Entry" }
  before_filter(only: [:show]) { add_crumb "Show Log Entry" }

  def index
    authorize @user, :publicly_visible_user?

    @search      = @user.dm_log_entries.search(params[:q])
    @log_entries = @search.result(distinct: false).page params[:page]
  end

  def show
    authorize @log_entry
  end

  def new
    @log_entry   = @user.dm_log_entries.new
    authorize @log_entry
  end

  def create
    @log_entry   = @user.dm_log_entries.build(log_entries_params)
    authorize @log_entry

    if @log_entry.save
      redirect_to [@user, DmLogEntry], flash: { notice: "Successfully created log entry #{@log_entry.id}" }
    else
      flash.now[:error] = "Failed to create log_entry #{@log_entry.id}: #{@log_entry.errors.full_messages.join(',')}"
      render :new
    end
  end

  def edit
    authorize @log_entry
  end

  def update
    authorize @log_entry

    if @log_entry.update_attributes(log_entries_params)
      redirect_to [@user, DmLogEntry], flash: { notice: "Successfully updated log entry #{@log_entry.id}" }
    else
      flash.now[:error] = "Failed to update log_entry #{@log_entry.id}: #{@log_entry.errors.full_messages.join(',')}"
      render :edit
    end
  end

  def destroy
    authorize @log_entry
    @log_entry.destroy

    redirect_to [@user, DmLogEntry], flash: { notice: "Successfully deleted DM Log Entry #{@log_entry.id}" }
  end


  protected
    def load_user
      @user   = User.find(params[:user_id])
    end

    def load_characters
      @characters  = @user.characters
    end

    def load_log_entry
      @log_entry   = LogEntry.find(params[:id])
    end

    def load_adventure_form_inputs
      @adventure_form_inputs  = AdventureFormInput.all
    end

    def load_overrides
      @use_adventure_override = !@adventure_form_inputs.find_by(name: @log_entry.adventure_title)
    end

    def log_entries_params
      params.require(:dm_log_entry).permit(:adventure_title, :session_num, :date_played, :xp_gained, :gp_gained, :renown_gained, :downtime_gained, :num_secret_missions, :num_magic_items_gained, :desc_magic_items_gained, :location_played, :dm_name, :dm_dci_number, :notes, :character_id)
    end
end