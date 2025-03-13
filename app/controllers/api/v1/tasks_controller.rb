module Api
  module V1
    class TasksController < BaseController
      def index
        tasks = Task.joins(:project).where(projects: { user_id: current_user.id })
        tasks = tasks.where(status: params[:status]) if params[:status].present?
        tasks = tasks.where(project: {id: params[:project_id]}) if params[:project_id].present?

        render json: tasks
      end

      def create
        project = current_user.projects.find(params[:project_id])
        task = project.tasks.build(task_params)
        if task.save
          CacheService.delete("user_#{current_user.id}_projects")
          render json: task, status: :created
        else
          render json: { errors: task.errors }, status: :unprocessable_entity
        end
      end

      def update
        task = Task.joins(:project)
                   .where(projects: { user_id: current_user.id })
                   .find(params[:id])

        if task.update(task_params)
          CacheService.delete("user_#{current_user.id}_projects")
          render json: task
        else
          render json: { errors: task.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        task = Task.joins(:project)
                   .where(projects: { user_id: current_user.id })
                   .find(params[:id])

        task.destroy
        CacheService.delete("user_#{current_user.id}_projects")
        head :no_content
      end

      private

      def task_params
        params.require(:task).permit(:title, :description, :status)
      end
    end
  end
end
