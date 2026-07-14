# frozen_string_literal: true

module Index
  # Facet item presenter that makes selecting multiple values within a single
  # facet behave as OR (inclusive) rather than Blacklight's default of AND.
  #
  # Clicking a value adds it to the facet's `f_inclusive` OR-group; clicking a
  # value already in the group removes just that value. Wire it onto a facet with
  # `item_presenter: Index::InclusiveFacetItemPresenter`, and set matching `tag:`
  # and `ex:` on the facet so its own OR-filter is excluded from its counts,
  # keeping sibling values visible while a group is active.
  #
  # This mirrors Blacklight::FacetGroupedItemPresenter, but derives the group
  # from the search state (the list component builds it with the standard
  # single-item presenter signature) and compares by `value` so it works with
  # both FacetItem objects and plain string values.
  class InclusiveFacetItemPresenter < Blacklight::FacetItemPresenter
    # The values currently in this facet's OR-group (its `f_inclusive` values).
    def group
      search_state.filter(facet_config).values(except: %i[filters missing]).flatten
    end

    def selected?
      group.include?(value)
    end

    # Add this value to the OR-group.
    def add_href(_path_options = {})
      return view_context.public_send(facet_config.url_method, facet_config.key, facet_item) if facet_config.url_method

      href_for_group(group + [value])
    end

    # Remove just this value from the OR-group.
    def remove_href(path = search_state)
      href_for_group(group - [value], path)
    end

    private

    # Replace the current OR-group with the given values and build the path.
    def href_for_group(values, path = search_state)
      new_state = path.filter(facet_config).remove(group)
      new_state = new_state.filter(facet_config).add(values)
      view_context.search_action_path(new_state)
    end
  end
end
