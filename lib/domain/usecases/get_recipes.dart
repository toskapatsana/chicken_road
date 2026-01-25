/// Domain Layer - GetRecipes Use Case
/// 
/// Use cases (also called Interactors) contain application-specific business
/// rules. They encapsulate and implement all of the use cases of the system.
/// 
/// Each use case represents a single action that the user can perform.
/// Use cases orchestrate the flow of data to and from entities, and direct
/// those entities to use their enterprise-wide business rules.
/// 
/// Use cases depend on repository interfaces, not implementations,
/// following the Dependency Inversion Principle.

import '../entities/recipe.dart';
import '../repositories/recipe_repository.dart';

/// Use case for retrieving all recipes.
/// 
/// This use case is responsible for fetching the complete list of recipes
/// from the repository. It's a simple pass-through in this case, but could
/// include additional business logic like sorting or validation.
class GetRecipes {
  final RecipeRepository repository;

  /// Constructor that receives the repository via dependency injection.
  /// The repository is an interface, so we don't know (or care) about
  /// the concrete implementation.
  GetRecipes(this.repository);

  /// Executes the use case.
  /// 
  /// Returns all recipes with their current favorite status.
  /// The call() method allows the use case to be invoked like a function.
  Future<List<Recipe>> call() async {
    return await repository.getRecipes();
  }
}
