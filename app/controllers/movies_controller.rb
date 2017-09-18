class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @movies = Movie.all
    @all_ratings = Movie.all_ratings
    
    if !(params[:sort].nil?)
      @sort_by = params[:sort]
      session[:sort] = params[:sort]
    elsif !(session[:sort].nil?)
      @sort_by = session[:sort]
    else 
      @sort_by = nil
    end
    
    if params[:commit] == "Refresh" and params[:ratings].nil?
      @filter = session[:ratings]
    elsif !(params[:ratings].nil?)
      @filter = params[:ratings]
      session[:ratings] = params[:ratings]
    elsif !(session[:ratings].nil?)
      @filter = session[:ratings]
    else
      @filter = nil
    end
    
    if params[:sort] != session[:sort] or params[:ratings] != session[:ratings]
      session[:sort] = @sort_by
      session[:ratings] = @filter
      redirect_to :sort => @sort_by, :ratings => @filter and return
    end
    
    if !(@sort_by.nil?) 
      @movies = @movies.order(@sort_by).all
    end
    if !(@filter.nil?)
      @movies = @movies.where(:rating => @filter.keys)
    end
    
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
