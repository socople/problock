#
class ProjectsController < ApplicationController
  def index
    @projects = Project.priority

    add_breadcrumb 'Inicio', root_url
    add_breadcrumb 'Proyectos', projects_url
  end
end
