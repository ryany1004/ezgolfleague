<template>
  <vue-modal name="tee-time-editor" height="auto" width="85%" :scrollable="false" @before-open="beforeOpen" clickToClose="true">
    <div class="edit-tee-times">
      <div class="edit-tee-times-header">
        <div class="row">
          <div class="col-md-8">
            <h2>Add Players</h2>
          </div>
        </div>
      </div>
      <div class="edit-tee-times-content">
          <div class="row no-gutters">
              <div class="col-md-4">
                <div class="edit-tee-times-left-content mCustomScrollbar" data-mcs-theme="dark">
                  <div class="edit-tee-times-left-content-style sortable">
                    <div class="media tee-time-widget" v-for="player in teeGroupData.nonRegisteredPlayers" v-bind:key="player.id">
                      <img :src=player.imageUrl>
                      <div class="media-body">
                        <h2>{{ player.name }}</h2>
                      </div>
                    </div>
                  </div>
                </div>
              </div>

              <div class="col-md-8">
                <nav id="autoScroll" class="navbar hidden">
                  <ul class="nav nav-pills">
                    <li class="nav-item">
                      <a class="nav-link" id="listScrollLink" href="#"></a>
                    </li>
                  </ul>
                </nav>
                <div class="edit-tee-times-right-content mCustomScrollbar" data-spy="scroll" data-target="#autoScroll" data-offset="50" data-mcs-theme="dark" id="sortable-groups">
                  <div class="addTeeTimeGreyBtn mt-2">
                    <p>Add Previous Tee Time</p>
                  </div>
                  <div v-for="tournamentGroup in teeGroupData.tournamentGroups" v-bind:key="tournamentGroup.id">
                    <div class="heading-style tee-time-popup">
                      <h2 class="text-uppercase">
                        <div class='input-group date editTeeTimeText' >
                          <input type='text' class="form-control editTeeTimeInput noBorder" value="TEE TIME TEXT"/>
                        </div>
                      </h2>
                      <span class="input-group-addon">
                        <i class="fas fa-pencil-alt editTeeTimeIcon" id="a"></i>
                      </span>
                      <i class="fas fa-trash"></i>
                    </div>
                    <div class="row sortable drag-player-row" v-for="(sliceGroup, index) in sliceTournamentGroupSlots(tournamentGroup.tournamentGroupSlots)" v-bind:key="index">
                      <template v-for="player in sliceGroup">
                        <div class="col-md-6 tee-time-widget" v-if="player.id != null">
                          <div class="media">
                            <img :src=player.imageUrl>
                            <div class="media-body">
                              <h2>{{ player.name }}</h2>
                            </div>
                          </div>
                        </div>
                        <div class="drag-player-box" v-else>
                          <div class="drag-player">
                            <p>Drag Player Here</p>
                          </div>
                        </div>
                      </template>
                    </div>
                    <div class="addTeeTimeGreyBtn">
                      <p>Add Next Tee Time</p>
                    </div>
                  </div>
                </div>
              </div>
          </div>
      </div> 
    </div> 
  </vue-modal>
</template>

<script>
export default {
  data() {
    return {
      teeGroupData: {
        nonRegisteredPlayers: [],
        tournamentGroups: [
          {
            tournamentGroupSlots: [],
          },
        ],
      },
    };
  },
  methods: {
    beforeOpen(event) {
      this.teeGroupData = event.params.teeGroupData;
    },
    sliceTournamentGroupSlots(groupSlots) {
      const sliceLength = 2;
      const slices = groupSlots.length / sliceLength;

      const sliced = [];

      var i = 0;
      for (; i < slices; i++) {
        const start = i * sliceLength;
        const end = (i + 1) * sliceLength;
        const slice = groupSlots.slice(start, end);

        sliced.push(slice);
      }

      return sliced;
    },
  },
};
</script>
