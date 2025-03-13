module Api
  module V1
    class ProjectsController < BaseController
      def index
        projects = CacheService.fetch("user_#{current_user.id}_projects") do
          current_user.projects.includes(:tasks).all
        end

        if projects.empty?
          render json: { message: 'No projects found' }, status: :not_found
        else
          render json: projects
        end
      end

      def show
        project = current_user.projects.includes(:tasks).find(params[:id])
        render json: project
      end

      def create
        project = current_user.projects.build(project_params)
        if project.save
          CacheService.delete("user_#{current_user.id}_projects")
          render json: project, status: :created
        else
          render json: { errors: project.errors }, status: :unprocessable_entity
        end
      end

      def update
        project = current_user.projects.find(params[:id])
        if project.update(project_params)
          CacheService.delete("user_#{current_user.id}_projects")
          render json: project
        else
          render json: { errors: project.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        project = current_user.projects.find(params[:id])
        project.destroy
        CacheService.delete("user_#{current_user.id}_projects")
        head :no_content
      end

      private

      def project_params
        params.require(:project).permit(:title, :description)
      end
    end
  end
end
